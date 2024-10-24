class CompleteTodoItemsJob < ApplicationJob
  queue_as :default

  # Incluir el módulo necesario para utilizar dom
  include ActionView::RecordIdentifier

  def perform(todo_list_id, selected_items)

    todo_list = TodoList.find(todo_list_id)
    todo_items = todo_list.todo_items.where(id: selected_items)

    # Marcar como completados los items seleccionados
    todo_items.update_all(is_completed: true)

    # Emitir una transmisión Turbo Stream para actualizar los items en la vista
    todo_items.each do |todo_item|
      Turbo::StreamsChannel.broadcast_replace_to(
        todo_list,
        target: dom_id(todo_item),
        partial: "todo_items/todo_item",
        locals: { todo_item: todo_item }
      )
    end
  end
end
