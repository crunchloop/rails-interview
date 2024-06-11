require 'rails_helper'

describe Api::TodoListsController do
  render_views

  describe 'GET index' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    context 'when format is HTML' do
      it 'raises a routing error' do
        expect {
          get :index
        }.to raise_error(ActionController::RoutingError, 'Not supported format')
      end
    end

    context 'when format is JSON' do
      it 'returns a success code' do
        get :index, format: :json

        expect(response.status).to eq(200)
      end

      it 'includes todo list records' do
        get :index, format: :json

        todo_lists = JSON.parse(response.body)

        aggregate_failures 'includes the id and name' do
          expect(todo_lists.count).to eq(1)
          expect(todo_lists[0].keys).to match_array(['id', 'name'])
          expect(todo_lists[0]['id']).to eq(todo_list.id)
          expect(todo_lists[0]['name']).to eq(todo_list.name)
        end
      end
    end
  end

  describe 'POST create' do
    context 'when format is JSON' do
      it 'when the name is empty' do
        post :create, params: { todo_list: { name: '' } }, as: :json

        expect(response.status).to eq(400)
      end

      it 'when the name is valid' do
        post :create, params: { todo_list: { name: 'TodoList name' } },  as: :json

        expect(response.status).to eq(201)
      end
    end
  end

  describe 'PUT update' do
    let!(:todo_list) { TodoList.create!(name: 'TodoList 1') }

    context 'when format is JSON' do
      it 'when the name is empty' do
        put :update, params: { id: todo_list.id, todo_list: { name: '' } }, as: :json

        expect(response.status).to eq(400)
      end

      it 'when the attributes are valid' do
        put :update, params: { id: todo_list.id, todo_list: { name: 'New name' } }, as: :json

        expect(response.status).to eq(200)
        todo_list_response = JSON.parse(response.body)

        aggregate_failures 'includes the id, name and done' do
          expect(todo_list_response.keys).to match_array(['id', 'name'])
          expect(todo_list_response['name']).to eq('New name')
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_list) { TodoList.create!(name: 'TodoList 1') }
    let!(:todo_item) { TodoItem.create!(name: 'Item 1', done: true, todo_list_id: todo_list.id) }
    let!(:todo_item_2) { TodoItem.create!(name: 'Item 2', done: true, todo_list_id: todo_list.id) }

    context 'when format is JSON' do
      it 'successfully removes' do
        delete :destroy, params: { id: todo_list.id }, as: :json

        expect(response.status).to eq(204)
        expect { TodoList.find(todo_list.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(TodoItem.count).to eq(0)
      end
    end
  end

  describe 'GET show' do
    let!(:todo_list) { TodoList.create!(name: 'TodoList 1') }

    context 'when format is JSON' do
      it 'returns a success code' do
        get :show, params: { id: todo_list.id }, format: :json

        expect(response.status).to eq(200)
      end

      it 'includes todo list record' do
        get :show, params: { id: todo_list.id }, format: :json

        todo_list_response = JSON.parse(response.body)

        aggregate_failures 'includes the id, name and done' do
          expect(todo_list_response.keys).to match_array(['id', 'name'])
          expect(todo_list_response['id']).to eq(todo_list.id)
          expect(todo_list_response['name']).to eq(todo_list.name)
        end
      end
    end
  end
end
