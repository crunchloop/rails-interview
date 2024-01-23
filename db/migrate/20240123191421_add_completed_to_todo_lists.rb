class AddCompletedToTodoLists < ActiveRecord::Migration[7.0]
  def change
    add_column :todo_lists, :completed, :boolean, default: false
  end
end
