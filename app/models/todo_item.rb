# frozen_string_literal: true

class TodoItem < ApplicationRecord
  belongs_to :todo_list, counter_cache: true

  scope :pending, -> { where(completed: false) }

  validates :description, length: { maximum: 1000 }, presence: true
end
