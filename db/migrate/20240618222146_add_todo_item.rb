# frozen_string_literal: true

class AddTodoItem < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_items do |t|
      t.string :name
      t.string :description
      t.boolean :completed
      t.references :todo_list, foreign_key: true, null: false

      t.timestamps
    end
  end
end
