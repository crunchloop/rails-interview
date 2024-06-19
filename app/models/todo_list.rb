# frozen_string_literal: true

class TodoList < ApplicationRecord
  has_many :todo_items

  validates :name, presence: true
end
