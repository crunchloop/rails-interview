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
require 'rails_helper'

describe TodoItem, type: :model do
  describe 'validations' do
    before do
      @todo_item = TodoItem.create!(title: 'Unique Title', todo_list: TodoList.create!(name: 'Unique Name'))
    end

    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:title) }
  end

  describe 'associations' do
    it { should belong_to(:todo_list) }
  end

  describe 'impact on TodoList completed status' do
    let!(:todo_list) { TodoList.create!(name: 'Test List') }
    let!(:todo_item) { todo_list.todo_items.create!(title: 'Test Item', completed: false) }
    let!(:todo_item_2) { todo_list.todo_items.create!(title: 'Test Item 2', completed: false) }

    it 'updates TodoList completed status when changed' do
      todo_item.update!(completed: true)
      todo_item_2.update!(completed: false)
      expect(todo_list.reload.completed?).to be false

      todo_item_2.update!(completed: true)
      expect(todo_list.reload.completed?).to be true
    end
  end
end
