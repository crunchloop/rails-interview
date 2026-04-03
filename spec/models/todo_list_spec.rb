require 'rails_helper'

RSpec.describe TodoList, type: :model do
  describe 'associations' do
    it 'has many todo list items' do
      list = create(:todo_list)
      item = create(:todo_item, todo_list: list)
      expect(list.todo_items).to include(item)
    end

    it 'destroys associated todo list items' do
      list = create(:todo_list)
      create(:todo_item, todo_list: list)
      expect { list.destroy }.to change(TodoItem, :count).by(-1)
    end
  end

  describe 'validations' do
    it 'is valid with a name' do
      list = build(:todo_list)
      expect(list).to be_valid
    end

    it 'is invalid without a name' do
      list = build(:todo_list, name: nil)
      expect(list).not_to be_valid
      expect(list.errors[:name]).to include("can't be blank")
    end
  end
end