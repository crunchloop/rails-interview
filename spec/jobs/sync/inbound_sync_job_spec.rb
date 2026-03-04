require "rails_helper"

RSpec.describe Sync::InboundSyncJob, type: :job do
  let(:now) { Time.current }
  let(:older) { 1.hour.ago }
  let(:newer) { 1.hour.from_now }

  describe "todo_list created" do
    let(:payload) do
      {
        "event" => "created",
        "resource_type" => "todo_list",
        "data" => { "id" => "ext-1", "source_id" => nil, "name" => "From External", "updated_at" => now.iso8601, "items" => [] }
      }
    end

    it "creates a new local TodoList" do
      expect { described_class.perform_now(payload) }.to change(TodoList, :count).by(1)
      expect(TodoList.find_by(external_id: "ext-1").name).to eq("From External")
    end

    it "does not enqueue outbound jobs" do
      expect {
        described_class.perform_now(payload)
      }.not_to have_enqueued_job(Sync::OutboundTodoListJob)
    end
  end

  describe "todo_list updated" do
    context "when external is newer" do
      let!(:todo_list) do
        list = TodoList.create!(name: "Old Name", external_id: "ext-1")
        list.update_columns(updated_at: older)
        list
      end

      let(:payload) do
        {
          "event" => "updated",
          "resource_type" => "todo_list",
          "data" => { "id" => "ext-1", "source_id" => todo_list.id.to_s, "name" => "New Name", "updated_at" => newer.iso8601, "items" => [] }
        }
      end

      it "updates the local record" do
        described_class.perform_now(payload)
        expect(todo_list.reload.name).to eq("New Name")
      end
    end

    context "when local is newer (conflict — local wins)" do
      let!(:todo_list) do
        list = TodoList.create!(name: "Local Name", external_id: "ext-1")
        list.update_columns(updated_at: newer)
        list
      end

      let(:payload) do
        {
          "event" => "updated",
          "resource_type" => "todo_list",
          "data" => { "id" => "ext-1", "source_id" => todo_list.id.to_s, "name" => "External Name", "updated_at" => older.iso8601, "items" => [] }
        }
      end

      it "does not overwrite the local record" do
        described_class.perform_now(payload)
        expect(todo_list.reload.name).to eq("Local Name")
      end
    end
  end

  describe "todo_list deleted" do
    let!(:todo_list) { TodoList.create!(name: "To Delete", external_id: "ext-1") }

    let(:payload) do
      {
        "event" => "deleted",
        "resource_type" => "todo_list",
        "data" => { "id" => "ext-1", "source_id" => todo_list.id.to_s }
      }
    end

    it "destroys the local TodoList" do
      expect { described_class.perform_now(payload) }.to change(TodoList, :count).by(-1)
    end
  end

  describe "todo_item upsert" do
    let!(:todo_list) { TodoList.create!(name: "List", external_id: "ext-list-1") }

    let(:payload) do
      {
        "event" => "created",
        "resource_type" => "todo_item",
        "data" => {
          "id" => "ext-item-1",
          "source_id" => nil,
          "todo_list_id" => "ext-list-1",
          "description" => "Do something",
          "completed" => false,
          "updated_at" => now.iso8601
        }
      }
    end

    it "creates a new local TodoItem under the correct list" do
      expect { described_class.perform_now(payload) }.to change(TodoItem, :count).by(1)
      item = TodoItem.find_by(external_id: "ext-item-1")
      expect(item.todo_list).to eq(todo_list)
      expect(item.description).to eq("Do something")
    end

    it "maps completed=true to state done" do
      payload["data"]["completed"] = true
      described_class.perform_now(payload)
      expect(TodoItem.find_by(external_id: "ext-item-1").state).to eq("done")
    end
  end

  describe "unknown resource_type" do
    let(:payload) { { "event" => "created", "resource_type" => "unknown", "data" => {} } }

    it "does not raise" do
      expect { described_class.perform_now(payload) }.not_to raise_error
    end
  end
end
