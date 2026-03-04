class TodoItem < ApplicationRecord
  include ExternalSyncable

  STATES = ["Ready for start", "In progress", "Done"].freeze

  belongs_to :todo_list

  enum :state, {
    ready_for_start: "Ready for start",
    in_progress: "In progress",
    done: "Done"
  }

  validates :title, presence: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[title description start_date end_date state]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[todo_list]
  end
end
