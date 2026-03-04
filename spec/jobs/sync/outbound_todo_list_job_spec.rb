require "rails_helper"

RSpec.describe Sync::OutboundTodoListJob, type: :job do
  let(:service) { instance_double(ExternalApi::TodoListSync) }

  before { allow(ExternalApi::TodoListSync).to receive(:new).and_return(service) }

  describe "create action" do
    let(:todo_list) { TodoList.create!(name: "My List") }
    let(:external_response) do
      {
        "id" => "ext-abc",
        "items" => [{ "id" => "ext-item-1", "source_id" => todo_list.todo_items.first&.id.to_s }]
      }
    end

    it "calls service.create and persists external_id" do
      allow(service).to receive(:create).and_return(external_response)
      described_class.perform_now(todo_list.id, :create)
      expect(todo_list.reload.external_id).to eq("ext-abc")
      expect(todo_list.reload.synced_at).to be_present
    end

    it "does not trigger outbound callbacks when saving external_id" do
      allow(service).to receive(:create).and_return(external_response)
      expect(described_class).not_to receive(:perform_later)
      described_class.perform_now(todo_list.id, :create)
    end
  end

  describe "update action" do
    let(:todo_list) { TodoList.create!(name: "My List", external_id: "ext-abc") }

    it "calls service.update and updates synced_at" do
      allow(service).to receive(:update).and_return({})
      described_class.perform_now(todo_list.id, :update)
      expect(todo_list.reload.synced_at).to be_present
      expect(todo_list.reload.sync_error).to be_nil
    end

    it "skips when external_id is blank" do
      list = TodoList.create!(name: "No ext id")
      expect(service).not_to receive(:update)
      described_class.perform_now(list.id, :update)
    end
  end

  describe "destroy action" do
    it "calls service.destroy with external_id" do
      allow(service).to receive(:destroy)
      described_class.perform_now(999, :destroy, external_id: "ext-abc")
      expect(service).to have_received(:destroy).with("ext-abc")
    end

    it "skips when external_id is blank" do
      expect(service).not_to receive(:destroy)
      described_class.perform_now(999, :destroy, external_id: nil)
    end
  end

  describe "error handling" do
    let(:todo_list) { TodoList.create!(name: "My List", external_id: "ext-abc") }

    it "persists sync_error on ApiError" do
      allow(service).to receive(:update).and_raise(ExternalApi::Client::ApiError.new(500, "server error"))
      # retry_on intercepts the error in test mode; we verify the side-effect (sync_error persisted)
      described_class.perform_now(todo_list.id, :update)
      expect(todo_list.reload.sync_error).to include("server error")
    end

    it "discards on RecordNotFound" do
      expect {
        described_class.perform_now(-1, :update)
      }.not_to raise_error
    end
  end
end
