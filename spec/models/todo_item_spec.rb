# frozen_string_literal: true

# spec/models/todo_item_spec.rb
require 'rails_helper'

RSpec.describe TodoItem, type: :model do
  let(:todo_list) { TodoList.create!(name: 'Sample Todo List') }
  let(:valid_attributes) { { name: 'Sample Todo Item', completed: false, todo_list: todo_list } }
  let(:invalid_attributes) { { name: '', completed: nil, todo_list: nil } }

  it 'is valid with valid attributes' do
    todo_item = TodoItem.new(valid_attributes)
    expect(todo_item).to be_valid
  end

  it 'is not valid without a name' do
    todo_item = TodoItem.new(valid_attributes.merge(name: ''))
    expect(todo_item).not_to be_valid
  end

  it 'is not valid with a description longer than 300 characters' do
    long_description = 'a' * 301
    todo_item = TodoItem.new(valid_attributes.merge(description: long_description))
    expect(todo_item).not_to be_valid
  end

  it 'is valid with a blank description' do
    todo_item = TodoItem.new(valid_attributes.merge(description: ''))
    expect(todo_item).to be_valid
  end

  it 'is not valid without a completed status' do
    todo_item = TodoItem.new(valid_attributes.merge(completed: nil))
    expect(todo_item).not_to be_valid
  end

  it 'is not valid without a todo_list_id' do
    todo_item = TodoItem.new(valid_attributes.merge(todo_list: nil))
    expect(todo_item).not_to be_valid
  end
end
