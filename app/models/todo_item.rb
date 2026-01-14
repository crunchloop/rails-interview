class TodoItem < ApplicationRecord
  belongs_to :todo_list

  validates :title, presence: true
  validate :cannot_uncomplete, on: :update

  private

  def cannot_uncomplete
    return unless will_save_change_to_complete?
    return unless complete_was == true

    errors.add(:complete, :cannot_uncomplete)
  end
end
