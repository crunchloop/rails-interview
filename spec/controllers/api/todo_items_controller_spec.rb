require 'rails_helper'

describe Api::TodoItemsController do
  render_views
  let!(:todo_list) { TodoList.create!(name: 'Setup RoR project') }

  describe 'GET index' do
    let!(:todo_item) { TodoItem.create!(name: 'Item 1', done: true, todo_list_id: todo_list.id) }

    context 'when format is HTML' do
      it 'raises a routing error' do
        expect {
          get :index, params: { todo_list_id: todo_list.id }
        }.to raise_error(ActionController::RoutingError, 'Not supported format')
      end
    end

    context 'when format is JSON' do
      it 'returns a success code' do
        get :index, params: { todo_list_id: todo_list.id }, format: :json

        expect(response.status).to eq(200)
      end

      it 'includes todo list records' do
        get :index, params: { todo_list_id: todo_list.id }, format: :json

        todo_items = JSON.parse(response.body)

        aggregate_failures 'includes the id, name and done' do
          expect(todo_items.count).to eq(1)
          expect(todo_items[0].keys).to match_array(['id', 'name', 'done'])
          expect(todo_items[0]['id']).to eq(todo_item.id)
          expect(todo_items[0]['name']).to eq(todo_item.name)
          expect(todo_items[0]['done']).to eq(todo_item.done)
        end
      end
    end
  end

  describe 'POST create' do
    context 'when format is JSON' do
      it 'when the name is empty' do
        post :create, params: { todo_list_id: todo_list.id, todo_item: { name: '' } }, as: :json

        expect(response.status).to eq(400)
      end

      it 'when the attributes are valid' do
        post :create, params: { todo_list_id: todo_list.id, todo_item: { name: 'TodoList name', done: false } }, as: :json

        expect(response.status).to eq(201)
        todo_item = JSON.parse(response.body)

        aggregate_failures 'includes the id, name and done' do
          expect(todo_item.keys).to match_array(['id', 'name', 'done'])
          expect(todo_item['name']).to eq('TodoList name')
          expect(todo_item['done']).to eq(false)
        end
      end
    end
  end

  describe 'PUT update' do
    let!(:todo_item) { TodoItem.create!(name: 'Item 1', done: true, todo_list_id: todo_list.id) }

    context 'when format is JSON' do
      it 'when the name is empty' do
        put :update, params: { todo_list_id: todo_list.id, id: todo_item.id, todo_item: { name: '' } }, as: :json

        expect(response.status).to eq(400)
      end

      it 'when the attributes are valid' do
        put :update, params: { todo_list_id: todo_list.id, id: todo_item.id, todo_item: { name: 'New name' } }, as: :json

        expect(response.status).to eq(200)
        todo_item_response = JSON.parse(response.body)

        aggregate_failures 'includes the id, name and done' do
          expect(todo_item_response.keys).to match_array(['id', 'name', 'done'])
          expect(todo_item_response['name']).to eq('New name')
          expect(todo_item_response['done']).to eq(todo_item.done)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_item) { TodoItem.create!(name: 'Item 1', done: true, todo_list_id: todo_list.id) }

    context 'when format is JSON' do
      it 'successfully removes' do
        delete :destroy, params: { todo_list_id: todo_list.id, id: todo_item.id }, as: :json

        expect(response.status).to eq(204)
        expect { TodoItem.find(todo_item.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET show' do
    let!(:todo_item) { TodoItem.create!(name: 'Item 1', done: true, todo_list_id: todo_list.id) }

    context 'when format is JSON' do
      it 'returns a success code' do
        get :show, params: { todo_list_id: todo_list.id, id: todo_item.id }, format: :json

        expect(response.status).to eq(200)
      end

      it 'includes todo list record' do
        get :show, params: { todo_list_id: todo_list.id, id: todo_item.id }, format: :json

        todo_item_response = JSON.parse(response.body)

        aggregate_failures 'includes the id, name and done' do
          expect(todo_item_response.keys).to match_array(['id', 'name', 'done'])
          expect(todo_item_response['id']).to eq(todo_item.id)
          expect(todo_item_response['name']).to eq(todo_item.name)
          expect(todo_item_response['done']).to eq(todo_item.done)
        end
      end
    end
  end
end
