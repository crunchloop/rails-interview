class TodoItem < ApplicationRecord
  STATES = ["Ready for start", "In progress", "Done"].freeze

  belongs_to :todo_list

  enum :state, {
    ready_for_start: "Ready for start",
    in_progress: "In progress",
    done: "Done"
  }

  validates :title, presence: true
end
