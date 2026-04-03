require 'rails_helper'

RSpec.describe TodoItem, type: :model do
  let(:todo_list) { create(:todo_list) }

  describe 'associations' do
    it 'belongs to a todo list' do
      item = create(:todo_item, todo_list: todo_list)
      expect(item.todo_list).to eq(todo_list)
    end
  end

  describe 'validations' do
    it 'is valid with a description and todo_list' do
      item = build(:todo_item, todo_list: todo_list)
      expect(item).to be_valid
    end

    it 'is invalid without a description' do
      item = build(:todo_item, description: nil, todo_list: todo_list)
      expect(item).not_to be_valid
      expect(item.errors[:description]).to include("can't be blank")
    end

    it 'is invalid without a todo_list' do
      item = build(:todo_item, todo_list: nil)
      expect(item).not_to be_valid
    end
  end

  describe 'defaults' do
    it 'sets completed to false by default' do
      item = create(:todo_item, todo_list: todo_list)
      expect(item.completed).to eq(false)
    end
  end
end
