require 'rails_helper'

RSpec.describe UpdateTodoItemStateJob, type: :job do
  let!(:todo_list) { TodoList.create!(name: 'My List') }
  let!(:item) { TodoItem.create!(title: 'Task', todo_list: todo_list) }

  it 'updates the item state' do
    described_class.perform_now(item.id, 'Done')

    expect(item.reload.state).to eq('done')
  end

  it 'enqueues a state_changed mailer email' do
    expect {
      described_class.perform_now(item.id, 'Done')
    }.to have_enqueued_mail(TodoItemMailer, :state_changed)
  end

  context 'when the TodoItem does not exist' do
    it 'discards the job without raising' do
      expect {
        described_class.perform_now(0, 'Done')
      }.not_to raise_error
    end
  end
end
