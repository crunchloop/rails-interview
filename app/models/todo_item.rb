class TodoItem < ApplicationRecord
  belongs_to :todo_list

  # Default value for is_complete
  attribute :is_complete, :boolean, default: false
end
