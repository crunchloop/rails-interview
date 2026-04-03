# frozen_string_literal: true

class AddTodoLists < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_lists do |t|
      t.string :name, null: false
    end
  end
end
