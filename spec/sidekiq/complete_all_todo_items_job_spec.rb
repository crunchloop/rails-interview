require "rails_helper"

RSpec.describe CompleteAllTodoItemsJob, type: :job do
  include ActiveJob::TestHelper

  before do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe "#perform" do
    context "when the todo list does not exist" do
      it "does nothing" do
        expect {
          described_class.perform_now(-1)
        }.not_to change { enqueued_jobs.size }
      end
    end

    context "when the todo list has no pending todo items" do
      let!(:todo_list) do
        FactoryBot.create(:todo_list, :with_completed_todo_items)
      end

      it "does not enqueue another job" do
        expect {
          described_class.perform_now(todo_list.id)
        }.not_to change { enqueued_jobs.size }
      end
    end

    context "when there are pending todo items within one batch" do
      let!(:todo_list) do
        FactoryBot.create(
          :todo_list,
          :with_pending_todo_items,
          todo_items_count: 3
        )
      end

      it "marks all pending items as completed" do
        described_class.perform_now(todo_list.id)

        expect(todo_list.todo_items.pending.count).to eq(0)
      end

      it "enqueues the next job with the last processed id" do
        last_item_id = todo_list.todo_items.order(:id).last.id

        described_class.perform_now(todo_list.id)

        expect(enqueued_jobs.last[:job]).to eq(described_class)
        expect(enqueued_jobs.last[:args]).to eq([todo_list.id, last_item_id])
      end
    end

    context "when there are more pending items than BATCH_SIZE" do
      let!(:todo_list) do
        FactoryBot.create(
          :todo_list,
          :with_pending_todo_items,
          todo_items_count: 3
        )
      end

      before do
        stub_const("#{described_class}::BATCH_SIZE", 2)
      end

      it "processes only one batch per execution" do
        described_class.perform_now(todo_list.id)

        expect(todo_list.todo_items.pending.count).to eq(1)
      end

      it "processes all items when jobs are executed recursively" do
        perform_enqueued_jobs do
          described_class.perform_later(todo_list.id)
        end

        expect(todo_list.todo_items.pending.count).to eq(0)
      end
    end

    context "when last_id is provided" do
      let!(:todo_list) do
        FactoryBot.create(
          :todo_list,
          :with_pending_todo_items,
          todo_items_count: 2
        )
      end

      it "only processes items with id greater than last_id" do
        older, newer = todo_list.todo_items.order(:id)

        described_class.perform_now(todo_list.id, older.id)

        expect(older.reload.is_completed).to be(false)
        expect(newer.reload.is_completed).to be(true)
      end
    end
  end
end
