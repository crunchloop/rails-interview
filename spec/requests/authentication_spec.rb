require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  let(:user) { create(:user, email: 'user@example.com', password: 'password123') }

  describe 'POST /signup' do
    it 'creates a new user and returns a token' do
      post '/signup', params: { email: 'newuser@example.com', password: 'password123', password_confirmation: 'password123' }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['token']).not_to be_nil
    end
  end

  describe 'POST /login' do
    it 'authenticates the user and returns a token' do
      post '/login', params: { email: user.email, password: 'password123' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['token']).not_to be_nil
    end

    it 'returns an error if credentials are invalid' do
      post '/login', params: { email: user.email, password: 'wrongpassword' }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
    end
  end
end
