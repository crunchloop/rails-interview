module BulkTodoListItems
  class KickoffJob < ApplicationJob
    queue_as :default

    BATCH_SIZE = 200

    # op_id: Integer
    # item_ids: Array<Integer> | nil
    def perform(op_id:, item_ids: nil)
      op = BulkOperation.find(op_id)
      op.update!(state: "running", started_at: Time.current, error_message: nil)

      ids = resolve_ids(op, item_ids)

      op.update!(total_count: ids.length, processed_count: 0)
      # No manual broadcast needed, handled by after_update_commit

      ids.each_slice(BATCH_SIZE) do |slice|
        BulkTodoListItems::BatchJob.perform_later(op_id: op.id, item_ids: slice)
      end

      # No records → finish immediately
      if ids.empty?
        op.update!(state: "finished", finished_at: Time.current)
      end
    rescue => e
      op&.update!(state: "failed", error_message: e.message, finished_at: Time.current)
      raise
    end

    private

    def resolve_ids(op, item_ids)
      scope = TodoListItem.where(todo_list_id: op.todo_list_id)
      case op.action
      when "delete_all", "mark_all_done"
        scope.where(status: :active).pluck(:id)
      else
        raise ArgumentError, "Unknown action: #{op.action}"
      end
    end
  end
end
