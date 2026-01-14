FactoryBot.define do
  factory :todo_item do
    association :todo_list
    complete { false }
    title { SecureRandom.uuid }
    description { SecureRandom.uuid }
  end
end
