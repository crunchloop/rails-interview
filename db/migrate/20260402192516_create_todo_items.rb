# frozen_string_literal: true

class CreateTodoItems < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_items do |t|
      t.string :description, null: false
      t.boolean :completed, null: false, default: false
      t.references :todo_list, null: false, foreign_key: true

      t.timestamps
    end
  end
end
