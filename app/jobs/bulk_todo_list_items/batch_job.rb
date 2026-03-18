module BulkTodoListItems
  class BatchJob < ApplicationJob
    queue_as :default

    def perform(op_id:, item_ids:)
      op = BulkOperation.find(op_id)
      return if op.finished? || op.failed?

      scope = TodoListItem.where(todo_list_id: op.todo_list_id, id: item_ids)

      # Perform DB actions
      case op.action
      when "delete_all"
        scope.delete_all
        item_ids.each do |id|
          Turbo::StreamsChannel.broadcast_remove_to(op.todo_list.user, "todo_lists", target: "todo_list_item_#{id}")
        end
      when "mark_all_done"
        scope.update_all(status: TodoListItem.statuses.fetch("closed"), updated_at: Time.current)
        items = TodoListItem.where(id: item_ids).includes(:todo_list)
        items.each do |item|
          Turbo::StreamsChannel.broadcast_replace_to(
            item.todo_list.user,
            "todo_lists",
            target: "todo_list_item_#{item.id}",
            partial: "todo_lists/todo_list_item",
            locals: { todo_list: item.todo_list, item: item }
          )
        end
      else
        raise ArgumentError, "Unknown action: #{op.action}"
      end

      # Update Op progress
      op.with_lock do
        op.processed_count += item_ids.length # Use item_ids length for accuracy
        if op.processed_count >= op.total_count
          op.state = "finished"
          op.finished_at = Time.current
        end
        op.save!
      end

      Rails.logger.info "[BatchJob] Progress for Op #{op.id}: #{op.processed_count}/#{op.total_count}"
    rescue => e
      Rails.logger.error "[BatchJob] Failed for Op #{op.id}: #{e.message}"
      op&.update!(state: "failed", error_message: e.message, finished_at: Time.current)
      raise
    end
  end
end
