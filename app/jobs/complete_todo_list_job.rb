class CompleteTodoListJob < ApplicationJob
  queue_as :default

  def perform(todo_list_id)
    todo_list = TodoList.find(todo_list_id)
    todo_list.todo_items.update_all(is_completed: true)
  end
end
