class CreateTodoListItems < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_list_items do |t|
      t.references :todo_list, null: false, foreign_key: true
      t.text :description
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end

