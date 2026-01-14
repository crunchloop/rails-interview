FactoryBot.define do
  factory :todo_list do
    items_completion_status { 'idle' }
    name { SecureRandom.alphanumeric(10) }
  end
end
