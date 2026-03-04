# rails-interview / TodoApi

[![Open in Coder](https://dev.crunchloop.io/open-in-coder.svg)](https://dev.crunchloop.io/templates/fly-containers/workspace?param.Git%20Repository=git@github.com:crunchloop/rails-interview.git)

This is a simple Todo List API built in Ruby on Rails 7. This project is currently being used for Ruby full-stack candidates.

## Build

To build the application:

`bin/setup`

## Run the API

To run the TodoApi in your local environment:

`bin/puma`

## Filtering and Pagination

Both index endpoints support filtering via [Ransack](https://github.com/activerecord-hackery/ransack) and pagination via [Kaminari](https://github.com/kaminari/kaminari).

### Query params

| Param | Example | Description |
|---|---|---|
| `q[field_predicate]` | `?q[name_cont]=shop` | Ransack filter |
| `page` | `?page=2` | Page number (default: 1) |
| `per_page` | `?per_page=5` | Items per page (default: 10) |

### Response format

```json
{
  "todo_lists": [...],
  "meta": {
    "current_page": 1,
    "total_pages": 3,
    "total_count": 25,
    "per_page": 10
  }
}
```

### TodoLists filter examples

```
GET /api/todolists?q[name_cont]=shopping
GET /api/todolists?page=2&per_page=5
```

### TodoItems filter examples

```
GET /api/todolists/:id/items?q[title_cont]=buy
GET /api/todolists/:id/items?q[state_eq]=Done
GET /api/todolists/:id/items?q[start_date_gteq]=2026-01-01
GET /api/todolists/:id/items?q[end_date_lteq]=2026-12-31
GET /api/todolists/:id/items?page=1&per_page=5
```

## External Sync — Webhook

The local API receives real-time change notifications from the external API via a webhook endpoint.

```
POST /api/sync/webhook
Content-Type: application/json
X-Webhook-Secret: <your_secret>   # only required if WEBHOOK_SECRET env var is set
```

### Payload format

| Field | Type | Values |
|---|---|---|
| `event` | string | `created`, `updated`, `deleted` |
| `resource_type` | string | `todo_list`, `todo_item` |
| `data` | object | resource attributes (see examples below) |

### Examples

**TodoList created on the external system:**
```bash
curl -X POST http://localhost:3000/api/sync/webhook \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Secret: your_secret" \
  -d '{
    "event": "created",
    "resource_type": "todo_list",
    "data": {
      "id": "ext-abc-123",
      "source_id": null,
      "name": "Shopping List",
      "updated_at": "2026-03-04T10:00:00Z",
      "items": [
        {
          "id": "ext-item-1",
          "source_id": null,
          "todo_list_id": "ext-abc-123",
          "description": "Buy milk",
          "completed": false,
          "updated_at": "2026-03-04T10:00:00Z"
        }
      ]
    }
  }'
```

**TodoList updated on the external system:**
```bash
curl -X POST http://localhost:3000/api/sync/webhook \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Secret: your_secret" \
  -d '{
    "event": "updated",
    "resource_type": "todo_list",
    "data": {
      "id": "ext-abc-123",
      "source_id": "42",
      "name": "Shopping List (updated)",
      "updated_at": "2026-03-04T11:00:00Z",
      "items": []
    }
  }'
```

**TodoItem updated on the external system:**
```bash
curl -X POST http://localhost:3000/api/sync/webhook \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Secret: your_secret" \
  -d '{
    "event": "updated",
    "resource_type": "todo_item",
    "data": {
      "id": "ext-item-1",
      "source_id": "7",
      "todo_list_id": "ext-abc-123",
      "description": "Buy milk and eggs",
      "completed": true,
      "updated_at": "2026-03-04T12:00:00Z"
    }
  }'
```

**TodoList deleted on the external system:**
```bash
curl -X POST http://localhost:3000/api/sync/webhook \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Secret: your_secret" \
  -d '{
    "event": "deleted",
    "resource_type": "todo_list",
    "data": {
      "id": "ext-abc-123",
      "source_id": "42"
    }
  }'
```

### Field notes

- `data.id` — the external system's own ID for the record
- `data.source_id` — our local record ID (sent to the external API as `source_id` when we first created it); can be `null` if the record originated in the external system
- `data.todo_list_id` — required for `todo_item` events; must be the external ID of the parent list
- **Conflict resolution:** if the local record has a newer `updated_at` than `data.updated_at`, the inbound update is ignored and the local version is preserved

### Environment variables

| Variable | Default | Description |
|---|---|---|
| `EXTERNAL_API_BASE_URL` | `http://localhost:3001` | Base URL of the external API (for outbound sync) |
| `WEBHOOK_SECRET` | _(none)_ | If set, all webhook requests must include `X-Webhook-Secret` header with this value |

## Test

To run tests:

`bin/rspec`

Check integration tests at: (https://github.com/crunchloop/interview-tests)

## Contact

- Santiago Doldán (sdoldan@crunchloop.io)

## About Crunchloop

![crunchloop](https://s3.amazonaws.com/crunchloop.io/logo-blue.png)

We strongly believe in giving back :rocket:. Let's work together [`Get in touch`](https://crunchloop.io/#contact).
