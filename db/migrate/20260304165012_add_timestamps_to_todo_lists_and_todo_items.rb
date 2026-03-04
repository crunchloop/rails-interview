class AddTimestampsToTodoListsAndTodoItems < ActiveRecord::Migration[8.1]
  def change
    add_timestamps :todo_lists, default: -> { "NOW()" }, null: false
    add_timestamps :todo_items, default: -> { "NOW()" }, null: false
  end
end
