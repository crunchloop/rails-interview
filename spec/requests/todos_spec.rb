require 'rails_helper'

RSpec.describe 'Todos', type: :request do
  let(:user) { create(:user, email: 'user@example.com', password: 'password123') }
  let(:headers) { { 'Authorization' => "Bearer #{JWT.encode({ user_id: user.id }, Rails.application.secrets.secret_key_base)}" } }

  describe 'POST /todos' do
    it 'creates a todo with valid token' do
      post '/todos', params: { title: 'Nuevo Todo' }, headers: headers
      expect(response).to have_http_status(:created)
    end

    it 'returns unauthorized error with no token' do
      post '/todos', params: { title: 'Nuevo Todo' }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['errors']).to eq('Unauthorized access')
    end
  end
end
