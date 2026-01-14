class CompleteTodoListItemsJob < ApplicationJob
  queue_as :default

  def perform(todo_list_id)
    todo_list = TodoList.find(todo_list_id)

    todo_list.processing!
    # Using update_all since we are updating multiple records at once
    # and we don't need callbacks or validations.
    todo_list.todo_items.where(complete: false).update_all(
      complete: true,
      updated_at: Time.current
    )

    todo_list.completed!

    # send completed email to user when implemented
    # TodoListMailer.items_processing_finished(user, todo_list).deliver_later
  rescue StandardError => e
    todo_list&.update(items_completion_error_message: e.message,
                      items_completion_status: TodoList.items_completion_statuses[:failed])
  end
end
