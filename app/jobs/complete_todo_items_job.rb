class CompleteTodoItemsJob < ApplicationJob
  queue_as :default

  # Incluir el módulo necesario para utilizar dom
  include ActionView::RecordIdentifier

  def perform(todo_list_id, selected_items)

    todo_list = TodoList.find(todo_list_id)
    todo_items = todo_list.todo_items.where(id: selected_items)

    # Iniciar una transacción para asegurar que todas las actualizaciones sean atómicas
    ActiveRecord::Base.transaction do
      todo_items.update_all(is_completed: true)

      # Emitir una transmisión Turbo Stream para actualizar los items en la vista
      todo_items.each do |todo_item|
        Turbo::StreamsChannel.broadcast_replace_to(
          todo_list,
          target: ActionView::RecordIdentifier.dom_id(todo_item),
          partial: 'todo_items/todo_item',
          locals: { todo_item: todo_item }
        )
      end
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "TodoList or TodoItems not found: #{e.message}"
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Validation failed for TodoItems: #{e.message}"
  rescue ActiveRecord::ConnectionNotEstablished => e
    Rails.logger.error "Database connection issue: #{e.message}"
    retry_job wait: 5.minutes, queue: :low_priority if executions < 3
  rescue StandardError => e
    Rails.logger.error "Unexpected error in CompleteTodoItemsJob: #{e.message}"
    raise e  # Decidir si volver a encolar el job o no
  end
end
