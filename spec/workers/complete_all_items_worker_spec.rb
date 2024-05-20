# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompleteAllItemsWorker, type: :worker do
  let!(:todo_list) { create(:todo_list) }
  let!(:todo_item) { create_list(:todo_item, 3, todo_list: todo_list, completed: false) }
  let!(:worker) { CompleteAllItemsWorker.new }

  it 'completes all items' do
    worker.perform(todo_list.id)

    todo_list.todo_items.reload

    expect(todo_list.todo_items.pluck(:completed).uniq).to eq([true])
  end

  it 'logs an error if the todo list is not found' do
    expect(Rails.logger).to receive(:error).with(
      'TodoList not found. CompleteAllItemsWorker failed for TodoList #-1'
    )

    worker.perform(-1)
  end
end
