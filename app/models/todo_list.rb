# == Schema Information
#
# Table name: todo_lists
#
#  id         :integer          not null, primary key
#  completed  :boolean          default(FALSE)
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class TodoList < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :todo_items, dependent: :destroy

  after_save :update_todo_items_completed_status!, if: :saved_change_to_completed_and_is_true?

  def update_completed_status!
    update(completed: todo_items.all?(&:completed))
  end

  private

  def saved_change_to_completed_and_is_true?
    saved_change_to_completed? && completed?
  end

  def update_todo_items_completed_status!
    todo_items.update_all(completed: completed) if completed?
  end
end
