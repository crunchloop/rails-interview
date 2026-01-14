require 'rails_helper'

RSpec.describe TodoItem, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:todo_list) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe 'custom validation: cannot_uncomplete' do
    let(:todo_list) { create(:todo_list) }

    context 'when complete changes from false to true' do
      it 'allows the update' do
        todo_item = create(
          :todo_item,
          todo_list: todo_list,
          complete: false
        )

        todo_item.complete = true

        expect(todo_item).to be_valid
      end
    end

    context 'when complete changes from true to false' do
      it 'is not valid' do
        todo_item = create(
          :todo_item,
          todo_list: todo_list,
          complete: true
        )

        todo_item.complete = false

        expect(todo_item).not_to be_valid
        expect(todo_item.errors[:complete])
          .to include("Can't change attribute once is completed")
      end
    end

    context 'when complete does not change' do
      it 'is valid' do
        todo_item = create(
          :todo_item,
          todo_list: todo_list,
          complete: true
        )

        todo_item.title = 'Updated title'

        expect(todo_item).to be_valid
      end
    end
  end
end
