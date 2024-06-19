# frozen_string_literal: true

class TodoItem < ApplicationRecord
  belongs_to :todo_list

  validates :name, presence: true
  validates :description, allow_blank: true, length: { maximum: 300 }
  validates :completed, inclusion: { in: [true, false] }
  validates :todo_list_id, presence: true
end
