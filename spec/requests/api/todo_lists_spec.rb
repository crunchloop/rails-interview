require 'rails_helper'

RSpec.describe 'Api::TodoLists', type: :request do
  let(:valid_params) { { todo_list: { name: 'Shopping' } } }
  let(:invalid_params) { { todo_list: { name: '' } } }

  describe 'GET /api/todolists' do
    let!(:todo_list) { TodoList.create!(name: 'Setup RoR project') }

    it 'returns HTTP 200' do
      get '/api/todolists', as: :json

      expect(response).to have_http_status(:ok)
    end

    it 'returns todo lists with pagination meta' do
      get '/api/todolists', as: :json

      body = JSON.parse(response.body)
      expect(body).to include('todo_lists', 'meta')
    end

    it 'includes the created record' do
      get '/api/todolists', as: :json

      todo_lists = JSON.parse(response.body)['todo_lists']
      expect(todo_lists.length).to eq(1)
      expect(todo_lists[0]).to include('id' => todo_list.id, 'name' => todo_list.name)
    end

    it 'returns only id and name fields per record' do
      get '/api/todolists', as: :json

      record = JSON.parse(response.body)['todo_lists'][0]
      expect(record.keys).to match_array(%w[id name])
    end

    context 'with ransack filtering' do
      let!(:other_list) { TodoList.create!(name: 'Work tasks') }

      it 'filters by name' do
        get '/api/todolists', params: { q: { name_cont: 'RoR' } }, as: :json

        todo_lists = JSON.parse(response.body)['todo_lists']
        expect(todo_lists.map { |t| t['name'] }).to include('Setup RoR project')
        expect(todo_lists.map { |t| t['name'] }).not_to include('Work tasks')
      end
    end

    context 'with pagination' do
      before { TodoList.create!(name: 'Extra list') }

      it 'respects per_page param' do
        get '/api/todolists', params: { per_page: 1 }, as: :json

        body = JSON.parse(response.body)
        expect(body['todo_lists'].length).to eq(1)
        expect(body['meta']['per_page']).to eq(1)
        expect(body['meta']['total_count']).to eq(2)
      end
    end
  end

  describe 'GET /api/todolists/:id' do
    let!(:todo_list) { TodoList.create!(name: 'Shopping') }

    it 'returns HTTP 200' do
      get "/api/todolists/#{todo_list.id}", as: :json

      expect(response).to have_http_status(:ok)
    end

    it 'returns the todo list' do
      get "/api/todolists/#{todo_list.id}", as: :json

      body = JSON.parse(response.body)
      expect(body).to include('id' => todo_list.id, 'name' => todo_list.name)
    end

    context 'when the record does not exist' do
      it 'returns HTTP 404' do
        get '/api/todolists/0', as: :json

        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        get '/api/todolists/0', as: :json

        expect(JSON.parse(response.body)).to include('error' => 'TodoList not found')
      end
    end
  end

  describe 'POST /api/todolists' do
    context 'with valid params' do
      it 'returns HTTP 201' do
        post '/api/todolists', params: valid_params, as: :json

        expect(response).to have_http_status(:created)
      end

      it 'creates a new TodoList' do
        expect {
          post '/api/todolists', params: valid_params, as: :json
        }.to change(TodoList, :count).by(1)
      end

      it 'returns the created record' do
        post '/api/todolists', params: valid_params, as: :json

        body = JSON.parse(response.body)
        expect(body).to include('name' => 'Shopping')
        expect(body['id']).not_to be_nil
      end
    end

    context 'with invalid params' do
      it 'returns HTTP 422' do
        post '/api/todolists', params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a record' do
        expect {
          post '/api/todolists', params: invalid_params, as: :json
        }.not_to change(TodoList, :count)
      end

      it 'returns validation errors' do
        post '/api/todolists', params: invalid_params, as: :json

        body = JSON.parse(response.body)
        expect(body['errors']).to be_present
      end
    end
  end

  describe 'PATCH /api/todolists/:id' do
    let!(:todo_list) { TodoList.create!(name: 'Old name') }

    context 'with valid params' do
      it 'returns HTTP 200' do
        patch "/api/todolists/#{todo_list.id}", params: { todo_list: { name: 'New name' } }, as: :json

        expect(response).to have_http_status(:ok)
      end

      it 'updates the record' do
        patch "/api/todolists/#{todo_list.id}", params: { todo_list: { name: 'New name' } }, as: :json

        expect(todo_list.reload.name).to eq('New name')
      end

      it 'returns the updated record' do
        patch "/api/todolists/#{todo_list.id}", params: { todo_list: { name: 'New name' } }, as: :json

        body = JSON.parse(response.body)
        expect(body).to include('id' => todo_list.id, 'name' => 'New name')
      end
    end

    context 'with invalid params' do
      it 'returns HTTP 422' do
        patch "/api/todolists/#{todo_list.id}", params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors' do
        patch "/api/todolists/#{todo_list.id}", params: invalid_params, as: :json

        body = JSON.parse(response.body)
        expect(body['errors']).to be_present
      end
    end

    context 'when the record does not exist' do
      it 'returns HTTP 404' do
        patch '/api/todolists/0', params: valid_params, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/todolists/:id' do
    let!(:todo_list) { TodoList.create!(name: 'To delete') }

    it 'returns HTTP 204' do
      delete "/api/todolists/#{todo_list.id}", as: :json

      expect(response).to have_http_status(:no_content)
    end

    it 'deletes the record' do
      expect {
        delete "/api/todolists/#{todo_list.id}", as: :json
      }.to change(TodoList, :count).by(-1)
    end

    context 'when the record does not exist' do
      it 'returns HTTP 404' do
        delete '/api/todolists/0', as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
