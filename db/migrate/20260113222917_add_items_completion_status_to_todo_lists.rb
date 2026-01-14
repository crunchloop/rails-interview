class AddItemsCompletionStatusToTodoLists < ActiveRecord::Migration[7.0]
  def change
    add_column :todo_lists, :items_completion_status, :string, null: false, default: 'idle'
    add_column :todo_lists, :items_completion_error_message, :string
  end
end
