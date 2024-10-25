class ChangeIsCompletedDefaultInTodoItems < ActiveRecord::Migration[6.1]
  def change
    change_column_default :todo_items, :is_completed, false
    change_column_null :todo_items, :is_completed, false
  end
end