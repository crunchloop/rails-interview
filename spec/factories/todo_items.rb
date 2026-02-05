FactoryBot.define do
  factory :todo_item do
    name { Faker::Lorem.sentence(word_count: 10) }
    association :todo_list
  end

  trait :completed do
    is_completed { true }
  end
end
