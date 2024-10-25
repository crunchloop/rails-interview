# spec/factories/todo_items.rb
FactoryBot.define do
  factory :todo_item do
    name { Faker::Lorem.sentence(word_count: 2) }
    description { Faker::Lorem.sentence(word_count: 10) }
    is_complete { false }
    association :todo_list
  end
end
