class AddCompletedToTodoItems < ActiveRecord::Migration[7.0]
  def change
    add_column :todo_items, :completed, :boolean, default: false
  end
end
