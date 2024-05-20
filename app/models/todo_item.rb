# frozen_string_literal: true

class TodoItem < ApplicationRecord
  belongs_to :todo_list

  validates :todo_list_id, presence: true
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :todo_list_id, presence: true
  validates :completed, inclusion: { in: [true, false] }
  validates :description, length: { maximum: 500 }, allow_blank: true
end
