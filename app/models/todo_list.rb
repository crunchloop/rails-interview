class TodoList < ApplicationRecord
  include ExternalSyncable

  has_many :todo_items, dependent: :destroy

  validates :name, presence: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[todo_items]
  end
end
