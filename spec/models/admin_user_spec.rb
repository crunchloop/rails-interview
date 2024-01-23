# == Schema Information
#
# Table name: admin_users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_admin_users_on_email                 (email) UNIQUE
#  index_admin_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require 'rails_helper'

describe AdminUser, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    # validate email uniqueness case insensitive
    it { should validate_uniqueness_of(:email).case_insensitive }
  end
end
