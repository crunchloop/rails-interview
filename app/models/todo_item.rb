class TodoItem < ApplicationRecord
  belongs_to :todo_list

  # Validations
  # validates :name, presence: true
  # validates :description, presence: true

  # Default value for is_complete
  attribute :is_complete, :boolean, default: false
end
