class TodoItemMailer < ApplicationMailer
  def state_changed(todo_item)
    @todo_item = todo_item
    # TODO: configure recipient (e.g., todo_item.todo_list.owner.email)
    mail(to: "placeholder@example.com", subject: "Todo item state changed")
  end
end
