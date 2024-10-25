# spec/factories/todo_lists.rb
FactoryBot.define do
  factory :todo_list do
    name { Faker::Lorem.sentence(word_count: 3) }

    trait :with_todo_items do
      transient do
        todo_items_count { 5 }
      end

      after(:create) do |todo_list, evaluator|
        create_list(:todo_item, evaluator.todo_items_count, todo_list: todo_list)
      end
    end
  end
end
