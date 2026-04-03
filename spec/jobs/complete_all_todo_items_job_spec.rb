require 'rails_helper'

RSpec.describe CompleteAllTodoItemsJob, type: :job do
  let(:todo_list) { create(:todo_list) }

  describe '#perform' do
    it 'marks all pending todo items as completed' do
      item1 = create(:todo_item, todo_list: todo_list)
      item2 = create(:todo_item, todo_list: todo_list)

      described_class.new.perform(todo_list.id)

      expect(item1.reload.completed).to be true
      expect(item2.reload.completed).to be true
    end

    it 'does not affect already completed items' do
      item = create(:todo_item, todo_list: todo_list, completed: true)

      described_class.new.perform(todo_list.id)

      expect(item.reload.completed).to be true
    end

    it 'does not affect items from other lists' do
      other_list = create(:todo_list)
      other_item = create(:todo_item, todo_list: other_list)

      described_class.new.perform(todo_list.id)

      expect(other_item.reload.completed).to be false
    end

    it 'processes items in batches' do
      expect_any_instance_of(ActiveRecord::Relation).to receive(:in_batches)
        .with(of: CompleteAllTodoItemsJob::BATCH_SIZE)
        .and_call_original

      described_class.new.perform(todo_list.id)
    end

    it 'raises ActiveRecord::RecordNotFound for invalid todo_list_id' do
      expect { described_class.new.perform(-1) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
