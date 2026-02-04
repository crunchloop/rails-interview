class TodoItem < ApplicationRecord
  belongs_to :todo_list

  scope :completed, -> { where(is_completed: true) }
  scope :pending, -> { where(is_completed: false) }

  def complete!
    update!(is_completed: true)
  end

  def undo_complete!
    update!(is_completed: false)
  end
end
