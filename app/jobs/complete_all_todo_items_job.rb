class CompleteAllTodoItemsJob < ApplicationJob
  queue_as :default

  BATCH_SIZE = 500

  def perform(todo_list_id, last_id = 0)
    todo_list = TodoList.find_by(id: todo_list_id)

    return if todo_list.nil?

    incomplete_todo_item_ids = todo_list.todo_items.pending
                                                    .where("id > ?", last_id)
                                                    .order(:id)
                                                    .limit(BATCH_SIZE)
                                                    .pluck(:id)

    return if incomplete_todo_item_ids.empty?

    TodoItem.where(id: incomplete_todo_item_ids).update_all(is_completed: true, updated_at: Time.current)

    self.class.perform_later(todo_list_id, incomplete_todo_item_ids.last)
  end
end
