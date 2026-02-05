FactoryBot.define do
  factory :todo_list do
    name { Faker::Job.title }
    description { Faker::Lorem.sentence(word_count: 25) }

    trait :with_pending_todo_items do
      transient do
        todo_items_count { 10 }
      end

      after(:create) do |todo_list, evaluator|
        create_list(:todo_item, evaluator.todo_items_count, todo_list: todo_list)
      end
    end

    trait :with_completed_todo_items do
      transient do
        todo_items_count { 10 }
      end

      after(:create) do |todo_list, evaluator|
        create_list(:todo_item, evaluator.todo_items_count, :completed, todo_list: todo_list)
      end
    end
  end
end
