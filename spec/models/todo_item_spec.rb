# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TodoItem, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:todo_list) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:todo_list_id) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(3).is_at_most(100) }
    it { is_expected.to validate_inclusion_of(:completed).in_array([true, false]) }
    it { is_expected.to validate_length_of(:description).is_at_most(500) }
  end
end
