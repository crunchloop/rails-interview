# == Schema Information
#
# Table name: todo_items
#
#  id           :integer          not null, primary key
#  completed    :boolean          default(FALSE)
#  description  :string
#  title        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  todo_list_id :integer          not null
#
# Indexes
#
#  index_todo_items_on_todo_list_id  (todo_list_id)
#
# Foreign Keys
#
#  todo_list_id  (todo_list_id => todo_lists.id)
#
class TodoItem < ApplicationRecord
  belongs_to :todo_list

  validates :title, presence: true, uniqueness: true

  after_save :update_todo_list_completed_status!, if: :saved_change_to_completed?

  private

  def update_todo_list_completed_status!
    todo_list.update_completed_status!
  end
end
