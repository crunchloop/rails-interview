require 'rails_helper'

RSpec.describe CompleteTodoListJob, type: :job do
  let!(:todo_list) { create(:todo_list) }
  let!(:todo_items) { create_list(:todo_item, 5, todo_list: todo_list, is_completed: false) }

  it "set all todo_items as completed" do
    CompleteTodoListJob.perform_now(todo_list.id)
    todo_list.reload.todo_items.each do |item|
      expect(item.is_completed).to be true
    end
  end

  it "get queued" do
    expect {
      CompleteTodoListJob.perform_later(todo_list.id)
    }.to have_enqueued_job(CompleteTodoListJob).with(todo_list.id)
  end
end
