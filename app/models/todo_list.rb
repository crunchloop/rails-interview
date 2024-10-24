class TodoList < ApplicationRecord
  has_many :todo_items, dependent: :destroy

  # Permitir la creación de items anidados
  accepts_nested_attributes_for :todo_items, allow_destroy: true
end