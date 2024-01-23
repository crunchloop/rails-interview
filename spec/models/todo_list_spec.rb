require 'rails_helper'

describe TodoList, type: :model do
  describe 'validations' do
    before do
      @todo_item = TodoList.create!(name: 'Unique Name')
    end

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:todo_items).dependent(:destroy) }
  end

  describe 'completed status' do
    let!(:todo_list) { TodoList.create!(name: 'Test List') }
    let!(:todo_item) { todo_list.todo_items.create!(title: 'Test Item', completed: false) }
    let!(:todo_item_2) { todo_list.todo_items.create!(title: 'Test Item 2', completed: false) }

    context 'when any todo item is not completed' do
      it 'is not marked as completed' do
        todo_item.update!(completed: true)
        expect(todo_list.reload.completed?).to be false
      end
    end

    context 'when all todo items are completed' do
      it 'is marked as completed' do
        todo_item.update!(completed: true)
        todo_item_2.update!(completed: true)
        expect(todo_list.reload.completed?).to be true
      end
    end

    it 'marks all items as completed when the list is marked as completed' do
      todo_item_2.update!(completed: false)

      todo_list.update!(completed: true)

      expect(todo_list.reload.todo_items.all?(&:completed)).to be true
    end
  end
end
