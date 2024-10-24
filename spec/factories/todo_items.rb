FactoryBot.define do
  factory :todo_item do
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    is_completed { false }
    association :todo_list
  end
end
