FactoryBot.define do
  factory :todo_list do
    name { Faker::Lorem.sentence(word_count: 3) }
  end
end
