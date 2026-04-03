FactoryBot.define do
  factory :todo_item do
    description { Faker::Lorem.sentence }
    completed { false }
    todo_list
  end
end
