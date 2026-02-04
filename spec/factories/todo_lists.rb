FactoryBot.define do
  factory :todo_list do
    name { Faker::Job.title }
    description { Faker::Lorem.sentence(word_count: 25) }
  end
end
