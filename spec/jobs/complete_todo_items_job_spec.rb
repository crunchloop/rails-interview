require 'rails_helper'

RSpec.describe CompleteTodoItemsJob, type: :job do
  let!(:todo_list) { create(:todo_list) }
  let!(:todo_items) { create_list(:todo_item, 5, todo_list: todo_list, is_completed: false) }

  describe "Success cases" do
    it "marks all todo_items as completed" do
      CompleteTodoItemsJob.perform_now(todo_list.id, todo_items.map(&:id))
      todo_list.reload.todo_items.each do |item|
        expect(item.is_completed).to be true
      end
    end

    it "queues the job" do
      expect {
        CompleteTodoItemsJob.perform_later(todo_list.id, todo_items.map(&:id))
      }.to have_enqueued_job(CompleteTodoItemsJob).with(todo_list.id, todo_items.map(&:id))
    end
  end

  describe "Error handling cases" do
    it "handles ActiveRecord::RecordNotFound when TodoList is not found" do
      expect {
        CompleteTodoItemsJob.perform_now(-1, todo_items.map(&:id))
      }.not_to raise_error
    end

    it "handles ActiveRecord::RecordInvalid when validation fails" do
      allow_any_instance_of(TodoItem).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
      expect {
        CompleteTodoItemsJob.perform_now(todo_list.id, todo_items.map(&:id))
      }.not_to raise_error
    end

    it "handles unexpected errors with StandardError" do
      allow(TodoList).to receive(:find).and_raise(StandardError, "Unexpected error")
      expect {
        CompleteTodoItemsJob.perform_now(todo_list.id, todo_items.map(&:id))
      }.to raise_error(StandardError, "Unexpected error")
    end
  end

  describe "Transaction handling" do
    it "ensures all updates are within a transaction" do
      expect(ActiveRecord::Base).to receive(:transaction).and_yield
      CompleteTodoItemsJob.perform_now(todo_list.id, todo_items.map(&:id))
    end
  end
end
