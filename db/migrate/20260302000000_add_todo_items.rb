class AddTodoItems < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_items do |t|
      t.string :title, null: false
      t.text :description
      t.date :start_date
      t.date :end_date
      t.string :state, null: false, default: "Ready for start"
      t.references :todo_list, null: false, foreign_key: true
    end
  end
end
