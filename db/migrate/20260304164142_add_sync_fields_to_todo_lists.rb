class AddSyncFieldsToTodoLists < ActiveRecord::Migration[8.1]
  def change
    add_column :todo_lists, :external_id, :string
    add_index :todo_lists, :external_id
    add_column :todo_lists, :synced_at, :datetime
    add_column :todo_lists, :sync_error, :text
  end
end
