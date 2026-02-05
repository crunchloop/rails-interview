require 'rails_helper'

RSpec.describe TodoList, type: :model do
  it { should have_many(:todo_items).dependent(:destroy) }
end
