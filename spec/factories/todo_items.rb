# frozen_string_literal: true

FactoryBot.define do
  factory :todo_item do
    name { 'Todo Item' }
    description { 'Testing Description' }
    completed { false }

    association(:todo_list)
  end
end
