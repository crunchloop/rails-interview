# spec/models/todo_list_spec.rb
require 'rails_helper'

RSpec.describe TodoList, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:todo_items).dependent(:destroy) }
  end

  describe 'enums' do
    it do
      is_expected.to define_enum_for(:items_completion_status)
        .with_values(
          idle: 'idle',
          processing: 'processing',
          completed: 'completed',
          failed: 'failed'
        )
        .backed_by_column_of_type(:string)
    end
  end

  describe '#has_uncompleted_items?' do
    let(:todo_list) { create(:todo_list) }

    context 'when all todo items are completed' do
      before do
        create_list(:todo_item, 2, todo_list: todo_list, complete: true)
      end

      it 'returns false' do
        expect(todo_list.has_uncompleted_items?).to be false
      end
    end

    context 'when at least one todo item is not completed' do
      before do
        create(:todo_item, todo_list: todo_list, complete: true)
        create(:todo_item, todo_list: todo_list, complete: false)
      end

      it 'returns true' do
        expect(todo_list.has_uncompleted_items?).to be true
      end
    end

    context 'when there are no todo items' do
      it 'returns false' do
        expect(todo_list.has_uncompleted_items?).to be false
      end
    end
  end
end
