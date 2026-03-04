require "rails_helper"

RSpec.describe "POST /api/sync/webhook", type: :request do
  let(:valid_payload) do
    {
      event: "updated",
      resource_type: "todo_list",
      data: { id: "ext-1", name: "Updated", updated_at: Time.current.iso8601, items: [] }
    }
  end

  describe "without WEBHOOK_SECRET set" do
    before { stub_const("ENV", ENV.to_hash.merge("WEBHOOK_SECRET" => nil)) }

    it "enqueues InboundSyncJob and returns 200" do
      expect {
        post "/api/sync/webhook", params: valid_payload, as: :json
      }.to have_enqueued_job(Sync::InboundSyncJob)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "with WEBHOOK_SECRET set" do
    let(:secret) { "supersecret" }

    before { stub_const("ENV", ENV.to_hash.merge("WEBHOOK_SECRET" => secret)) }

    it "returns 200 with correct secret header" do
      post "/api/sync/webhook",
           params: valid_payload,
           headers: { "X-Webhook-Secret" => secret },
           as: :json

      expect(response).to have_http_status(:ok)
    end

    it "returns 401 with wrong secret" do
      post "/api/sync/webhook",
           params: valid_payload,
           headers: { "X-Webhook-Secret" => "wrong" },
           as: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 without secret header" do
      post "/api/sync/webhook", params: valid_payload, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "with invalid payload" do
    it "returns 422 for missing event" do
      post "/api/sync/webhook",
           params: { resource_type: "todo_list", data: { id: "ext-1" } },
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 for unknown resource_type" do
      post "/api/sync/webhook",
           params: { event: "created", resource_type: "unknown", data: { id: "ext-1" } },
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
