class AddDescriptionToTodoLists < ActiveRecord::Migration[7.0]
  def change
    add_column :todo_lists, :description, :text
  end
end
