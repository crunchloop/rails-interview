class CompleteAllItemsWorker
  include Sidekiq::Worker

  def perform(todo_list_id)
    TodoList.find(todo_list_id).todo_items.update_all(completed: true)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "TodoList not found. CompleteAllItemsWorker failed for TodoList ##{todo_list_id}"
  end
end
