class TodoList < ApplicationRecord
  has_many :todo_items, dependent: :destroy

  enum :items_completion_status, {
    idle: 'idle',
    processing: 'processing',
    completed: 'completed',
    failed: 'failed'
  }

  def has_uncompleted_items?
    todo_items.any? { |todo_item| !todo_item.complete? }
  end
end
