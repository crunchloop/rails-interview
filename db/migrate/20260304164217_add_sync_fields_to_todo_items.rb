class AddSyncFieldsToTodoItems < ActiveRecord::Migration[8.1]
  def change
    add_column :todo_items, :external_id, :string
    add_index :todo_items, :external_id
    add_column :todo_items, :synced_at, :datetime
    add_column :todo_items, :sync_error, :text
  end
end
