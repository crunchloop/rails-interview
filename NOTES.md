# NOTES — Synchronization Design Decisions

## 1. High-Level Overview

The synchronization system keeps the local Todo API in sync with an external API. It operates in two directions:

- **Outbound (local → external):** ActiveRecord `after_commit` callbacks enqueue Sidekiq background jobs that propagate local changes to the external API using Faraday.
- **Inbound (external → local):** The external API pushes changes to a local webhook endpoint (`POST /api/sync/webhook`), which immediately enqueues an `InboundSyncJob` for async processing.

The separation of concerns is: models trigger jobs via a shared concern, jobs orchestrate the sync logic, and services handle the actual HTTP communication.

---

## 2. Key Design Decisions

### ActiveRecord callbacks → async jobs
Callbacks fire on `after_commit` (not `after_save`) to ensure the DB transaction is committed before any sync attempt. Jobs are async so user-facing requests are not blocked by external API latency or failures.

### `ExternalSyncable` concern + `skip_sync` flag
A thread-local `skip_sync_callbacks` flag prevents circular sync loops. When inbound jobs write to the DB, they wrap operations in `TodoList.skip_sync { ... }`, preventing those writes from triggering outbound jobs back to the external API.

### Identity mapping via `external_id` + `source_id`
- Local records store `external_id` (the ID assigned by the external API).
- When creating a record in the external API, we send our local `id` as `source_id`.
- This two-way mapping allows finding the correct record regardless of which system initiates the sync.

### Conflict resolution: local wins if `updated_at` is newer
When an inbound event arrives, `updated_at` timestamps are compared. If the local record was updated more recently than the external one, the inbound update is skipped. This prevents overwriting in-flight local edits with stale external data.

### Retry strategy
Jobs use ActiveJob's `retry_on` with `polynomially_longer` backoff (3 attempts) for transient `ApiError`s. `NotFoundError` (404) and `RecordNotFound` are discarded immediately with a log warning, since retrying would not help.

### Dedicated Sidekiq queue: `sync`
Sync jobs run in a separate `sync` queue to avoid competing with user-facing jobs (`default`) and email (`mailers`). This allows independent scaling and priority tuning.

### Webhook security
An optional `WEBHOOK_SECRET` environment variable can be set. If present, all webhook requests must include an `X-Webhook-Secret` header with the matching value, validated via `ActiveSupport::SecurityUtils.secure_compare` (timing-safe).

---

## 3. Resilience and Error Handling

- **Transient failures (network, 5xx):** Retried up to 3 times with exponential backoff via `retry_on`.
- **Permanent failures (404, 422):** Discarded with a warning log. The `sync_error` column on the model persists the last error message for visibility.
- **Partial failures in list creation:** If syncing a list succeeds but persisting `external_id` fails locally, the next outbound update will skip (no `external_id`) and log a warning. A manual re-sync can be triggered.
- **Webhook duplicate delivery:** The inbound job is idempotent — upsert operations are safe to run multiple times with the same data.

---

## 4. Edge Cases

### New items added to an already-synced list
The external API provides no `POST /todolists/:id/todoitems` endpoint. Items can only be created via `POST /todolists` (at list creation time). As a result:
- When a new `TodoItem` is created locally on an existing list, the outbound job logs a skip and takes no action.
- The item will only appear in the external system if the external API triggers an inbound webhook that includes it.

**Suggested API improvement:** Add `POST /todolists/:id/todoitems` to the external API. This would allow full bidirectional item creation and is the only missing endpoint for complete sync coverage.

### Cascading deletes
When a `TodoList` is destroyed locally, Rails cascades the destruction to its `TodoItems`. The outbound destroy job for the list triggers `DELETE /todolists/:external_id` on the external API, which also deletes the items there (per the external API spec). Individual item destroy callbacks are suppressed via `dependent: :destroy` cascade behavior since the parent deletion handles it.

### Records without `external_id`
If a record was created locally before the sync system was deployed, it has no `external_id`. Update/destroy jobs detect this and skip with a log entry. These records can be backfilled by re-triggering a create sync manually.

---

## 5. Areas for Improvement

- **Backfill task:** A rake task to sync all existing records that have no `external_id` would be needed in a production deployment.
- **Webhook payload normalization:** Currently the webhook contract is informal. A formal JSON Schema or OpenAPI spec for the webhook payload would improve reliability.
- **Idempotency key:** Adding a unique `idempotency_key` to outbound requests would prevent duplicate records on the external API if a job retries after a network timeout where the external API already processed the request.
- **Observability:** Integrating with a metrics system (e.g., Datadog, Prometheus) to track sync success/failure rates per resource type would aid production monitoring.
- **Batch sync:** For large datasets, a bulk-fetch-and-compare approach (fetching all external records once and diffing locally) would be more efficient than per-record operations.

---

## 6. Assumptions

- The external API's `source_id` field is intended to store our local record ID (string), and is returned on all responses.
- The external API sends webhooks as `POST` requests with a JSON body matching the documented event format.
- `updated_at` timestamps from the external API are in ISO 8601 format and represent UTC times.
- Deleting a `TodoList` on the external API also deletes all its `TodoItem`s (per the API spec), so we do not need to issue individual item delete calls when the parent list is deleted.
- The `title` field (required locally but absent from the external API model) is populated from `description` when creating items inbound. If `description` is blank, it defaults to "Untitled".
