require 'rails_helper'

RSpec.describe 'Api::TodoItems', type: :request do
  let!(:todo_list) { TodoList.create!(name: 'Shopping') }

  let(:valid_params) { { todo_item: { title: 'Buy milk' } } }
  let(:invalid_params) { { todo_item: { title: '' } } }

  describe 'GET /api/todolists/:todo_list_id/items' do
    let!(:todo_item) { todo_list.todo_items.create!(title: 'Buy milk') }

    it 'returns HTTP 200' do
      get "/api/todolists/#{todo_list.id}/items", as: :json

      expect(response).to have_http_status(:ok)
    end

    it 'returns todo items with pagination meta' do
      get "/api/todolists/#{todo_list.id}/items", as: :json

      body = JSON.parse(response.body)
      expect(body).to include('todo_items', 'meta')
    end

    it 'includes the created record' do
      get "/api/todolists/#{todo_list.id}/items", as: :json

      todo_items = JSON.parse(response.body)['todo_items']
      expect(todo_items.length).to eq(1)
      expect(todo_items[0]).to include('id' => todo_item.id, 'title' => todo_item.title)
    end

    it 'returns the expected fields per record' do
      get "/api/todolists/#{todo_list.id}/items", as: :json

      record = JSON.parse(response.body)['todo_items'][0]
      expect(record.keys).to match_array(%w[id title description start_date end_date state todo_list_id])
    end

    it 'only returns items belonging to the todo list' do
      other_list = TodoList.create!(name: 'Work')
      other_list.todo_items.create!(title: 'Other item')

      get "/api/todolists/#{todo_list.id}/items", as: :json

      todo_items = JSON.parse(response.body)['todo_items']
      expect(todo_items.length).to eq(1)
      expect(todo_items[0]['todo_list_id']).to eq(todo_list.id)
    end

    context 'with ransack filtering' do
      let!(:done_item) { todo_list.todo_items.create!(title: 'Buy eggs', state: 'Done') }

      it 'filters by title' do
        get "/api/todolists/#{todo_list.id}/items", params: { q: { title_cont: 'milk' } }, as: :json

        titles = JSON.parse(response.body)['todo_items'].map { |i| i['title'] }
        expect(titles).to include('Buy milk')
        expect(titles).not_to include('Buy eggs')
      end

      it 'filters by state' do
        get "/api/todolists/#{todo_list.id}/items",
            params: { q: { state_eq: 'Done' } }, as: :json

        items = JSON.parse(response.body)['todo_items']
        expect(items.map { |i| i['state'] }).to all(eq('done'))
      end
    end

    context 'with pagination' do
      before { todo_list.todo_items.create!(title: 'Buy bread') }

      it 'respects per_page param' do
        get "/api/todolists/#{todo_list.id}/items", params: { per_page: 1 }, as: :json

        body = JSON.parse(response.body)
        expect(body['todo_items'].length).to eq(1)
        expect(body['meta']['per_page']).to eq(1)
        expect(body['meta']['total_count']).to eq(2)
      end
    end

    context 'when the todo list does not exist' do
      it 'returns HTTP 404' do
        get '/api/todolists/0/items', as: :json

        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        get '/api/todolists/0/items', as: :json

        expect(JSON.parse(response.body)).to include('error' => 'TodoList not found')
      end
    end
  end

  describe 'GET /api/todolists/:todo_list_id/items/:id' do
    let!(:todo_item) { todo_list.todo_items.create!(title: 'Buy milk') }

    it 'returns HTTP 200' do
      get "/api/todolists/#{todo_list.id}/items/#{todo_item.id}", as: :json

      expect(response).to have_http_status(:ok)
    end

    it 'returns the todo item' do
      get "/api/todolists/#{todo_list.id}/items/#{todo_item.id}", as: :json

      body = JSON.parse(response.body)
      expect(body).to include('id' => todo_item.id, 'title' => todo_item.title)
    end

    context 'when the todo item does not exist' do
      it 'returns HTTP 404' do
        get "/api/todolists/#{todo_list.id}/items/0", as: :json

        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        get "/api/todolists/#{todo_list.id}/items/0", as: :json

        expect(JSON.parse(response.body)).to include('error' => 'TodoItem not found')
      end
    end

    context 'when the todo list does not exist' do
      it 'returns HTTP 404' do
        get "/api/todolists/0/items/#{todo_item.id}", as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/todolists/:todo_list_id/items' do
    context 'with valid params' do
      it 'returns HTTP 201' do
        post "/api/todolists/#{todo_list.id}/items", params: valid_params, as: :json

        expect(response).to have_http_status(:created)
      end

      it 'creates a new TodoItem' do
        expect {
          post "/api/todolists/#{todo_list.id}/items", params: valid_params, as: :json
        }.to change(TodoItem, :count).by(1)
      end

      it 'associates the item with the todo list' do
        post "/api/todolists/#{todo_list.id}/items", params: valid_params, as: :json

        body = JSON.parse(response.body)
        expect(body['todo_list_id']).to eq(todo_list.id)
      end

      it 'returns the created record' do
        post "/api/todolists/#{todo_list.id}/items", params: valid_params, as: :json

        body = JSON.parse(response.body)
        expect(body).to include('title' => 'Buy milk')
        expect(body['id']).not_to be_nil
      end

      it 'sets default state to ready_for_start' do
        post "/api/todolists/#{todo_list.id}/items", params: valid_params, as: :json

        expect(JSON.parse(response.body)['state']).to eq('ready_for_start')
      end

      it 'accepts all optional fields' do
        params = {
          todo_item: {
            title: 'Buy milk',
            description: 'Full fat milk',
            start_date: '2026-03-01',
            end_date: '2026-03-05',
            state: 'In progress'
          }
        }

        post "/api/todolists/#{todo_list.id}/items", params: params, as: :json

        body = JSON.parse(response.body)
        expect(body).to include(
          'title' => 'Buy milk',
          'description' => 'Full fat milk',
          'start_date' => '2026-03-01',
          'end_date' => '2026-03-05',
          'state' => 'in_progress'
        )
      end
    end

    context 'with invalid params' do
      it 'returns HTTP 422' do
        post "/api/todolists/#{todo_list.id}/items", params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a record' do
        expect {
          post "/api/todolists/#{todo_list.id}/items", params: invalid_params, as: :json
        }.not_to change(TodoItem, :count)
      end

      it 'returns validation errors' do
        post "/api/todolists/#{todo_list.id}/items", params: invalid_params, as: :json

        body = JSON.parse(response.body)
        expect(body['errors']).to be_present
      end
    end

    context 'when the todo list does not exist' do
      it 'returns HTTP 404' do
        post '/api/todolists/0/items', params: valid_params, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PATCH /api/todolists/:todo_list_id/items/:id' do
    let!(:todo_item) { todo_list.todo_items.create!(title: 'Buy milk') }

    context 'with valid params' do
      it 'returns HTTP 200' do
        patch "/api/todolists/#{todo_list.id}/items/#{todo_item.id}",
              params: { todo_item: { title: 'Buy oat milk' } }, as: :json

        expect(response).to have_http_status(:ok)
      end

      it 'updates the record' do
        patch "/api/todolists/#{todo_list.id}/items/#{todo_item.id}",
              params: { todo_item: { title: 'Buy oat milk' } }, as: :json

        expect(todo_item.reload.title).to eq('Buy oat milk')
      end

      it 'returns the updated record' do
        patch "/api/todolists/#{todo_list.id}/items/#{todo_item.id}",
              params: { todo_item: { state: 'Done' } }, as: :json

        body = JSON.parse(response.body)
        expect(body).to include('id' => todo_item.id, 'state' => 'done')
      end
    end

    context 'with invalid params' do
      it 'returns HTTP 422' do
        patch "/api/todolists/#{todo_list.id}/items/#{todo_item.id}",
              params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors' do
        patch "/api/todolists/#{todo_list.id}/items/#{todo_item.id}",
              params: invalid_params, as: :json

        body = JSON.parse(response.body)
        expect(body['errors']).to be_present
      end
    end

    context 'when the todo item does not exist' do
      it 'returns HTTP 404' do
        patch "/api/todolists/#{todo_list.id}/items/0",
              params: valid_params, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the todo list does not exist' do
      it 'returns HTTP 404' do
        patch "/api/todolists/0/items/#{todo_item.id}",
              params: valid_params, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/todolists/:todo_list_id/items/:id' do
    let!(:todo_item) { todo_list.todo_items.create!(title: 'Buy milk') }

    it 'returns HTTP 204' do
      delete "/api/todolists/#{todo_list.id}/items/#{todo_item.id}", as: :json

      expect(response).to have_http_status(:no_content)
    end

    it 'deletes the record' do
      expect {
        delete "/api/todolists/#{todo_list.id}/items/#{todo_item.id}", as: :json
      }.to change(TodoItem, :count).by(-1)
    end

    context 'when the todo item does not exist' do
      it 'returns HTTP 404' do
        delete "/api/todolists/#{todo_list.id}/items/0", as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the todo list does not exist' do
      it 'returns HTTP 404' do
        delete "/api/todolists/0/items/#{todo_item.id}", as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
