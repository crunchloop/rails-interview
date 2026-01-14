require 'rails_helper'

RSpec.describe CompleteTodoListItemsJob, type: :job do
  let(:todo_list) do
    create(
      :todo_list,
      items_completion_status: 'idle',
      items_completion_error_message: nil
    )
  end

  let!(:completed_item) do
    create(:todo_item, todo_list: todo_list, complete: true)
  end

  let!(:uncompleted_item) do
    create(:todo_item, todo_list: todo_list, complete: false)
  end

  describe '#perform' do
    context 'when everything works correctly' do
      it 'marks all items as complete' do
        described_class.perform_now(todo_list.id)

        expect(uncompleted_item.reload.complete).to be true
        expect(completed_item.reload.complete).to be true
      end

      it 'sets the todo list status to completed' do
        described_class.perform_now(todo_list.id)

        expect(todo_list.reload.items_completion_status).to eq('completed')
      end
    end

    context 'when an error occurs after the todo list is loaded' do
      before do
        allow_any_instance_of(TodoList)
          .to receive(:processing!)
          .and_raise(StandardError, 'Internal error')
      end

      it 'sets status to failed' do
        described_class.perform_now(todo_list.id)

        expect(todo_list.reload.items_completion_status).to eq('failed')
      end

      it 'stores the error message' do
        described_class.perform_now(todo_list.id)

        expect(todo_list.reload.items_completion_error_message).to eq('Internal error')
      end
    end
  end

  describe 'queueing' do
    it 'is enqueued on the default queue' do
      expect {
        described_class.perform_later(todo_list.id)
      }.to have_enqueued_job(described_class)
        .with(todo_list.id)
        .on_queue('default')
    end
  end
end
