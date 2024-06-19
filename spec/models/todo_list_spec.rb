# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TodoList, type: :model do
  let(:valid_attributes) { { name: 'Sample Todo List' } }
  let(:invalid_attributes) { { name: '' } }

  it 'is valid with valid attributes' do
    todo_list = TodoList.new(valid_attributes)
    expect(todo_list).to be_valid
  end

  it 'is not valid without a name' do
    todo_list = TodoList.new(invalid_attributes)
    expect(todo_list).not_to be_valid
  end

  it 'destroys associated todo_items when destroyed' do
    todo_list = TodoList.create!(valid_attributes)
    todo_list.todo_items.create!(name: 'Sample Todo Item', completed: false)
    expect { todo_list.destroy }.to change(TodoItem, :count).by(-1)
  end
end
