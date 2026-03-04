class UpdateTodoItemStateJob < ApplicationJob
  queue_as :default
  discard_on ActiveRecord::RecordNotFound

  def perform(todo_item_id, new_state)
    item = TodoItem.find(todo_item_id)
    state_key = TodoItem.states.key(new_state) || new_state
    item.update!(state: state_key)

    Turbo::StreamsChannel.broadcast_replace_to(
      item.todo_list,
      target: item,
      partial: "todo_items/todo_item",
      locals: { todo_item: item }
    )
    Rails.logger.info("State changes for item: #{item.id}, #{item.state}")

    # Send notification email
    TodoItemMailer.state_changed(item).deliver_later

    # TODO: Add other side-effect tasks here (e.g., webhooks, audit log, etc.)
  end
end
