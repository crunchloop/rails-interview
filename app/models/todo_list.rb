# frozen_string_literal: true

class TodoList < ApplicationRecord
    has_many :todo_items, dependent: :destroy

    validates :name, length: { maximum: 150 }, presence: true
end
