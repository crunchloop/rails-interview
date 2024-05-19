FactoryBot.define do
  factory :todo_item do
    association(:todo_list)

    name { 'Todo item' }
    description { 'This is a todo item' }
    completed { false }
  end
end
