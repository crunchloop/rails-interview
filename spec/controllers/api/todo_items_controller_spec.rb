# frozen_string_literal: true

require 'rails_helper'

describe Api::TodoItemsController do
  render_views

  describe 'POST create' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    context 'when params is valid' do
      let(:params) do
        { 'todo_list_id' => todo_list.id,
          'todo_item' =>
          { 'name' => 'Test Item',
            'description' => 'Item Description',
            'completed' => false } }
      end
      let(:todo_item_params) do
        { 'todo_item' => { 'id' => 1,
                           'name' => 'Test Item',
                           'description' => 'Item Description',
                           'completed' => false, 'todo_list_id' => todo_list.id } }
      end

      it 'returns created code' do
        post :create, params: params, format: :json

        expect(response.status).to eq(201)
      end

      it 'returns correct todo item' do
        post :create, params: params, format: :json

        expect(JSON.parse(response.body)).to eq(todo_item_params)
      end
    end

    context 'when params is invalid' do
      let(:params) do
        { 'todo_list_id' => 100,
          'todo_item' =>
          { 'name' => 'Test Item',
            'description' => 'Item Description',
            'completed' => 'true' } }
      end

      it 'returns fail code' do
        post :create, params: params, format: :json

        expect(response.status).to eq(404)
      end

      it 'returns error in response' do
        post :create, params: params, format: :json

        expect(JSON.parse(response.body)).to eq({ 'error' => 'Record not found' })
      end
    end
  end

  describe 'GET index' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }
    let!(:todo_item) do
      todo_list.todo_items.create(name: 'Test Item', description: 'Item Description', completed: false)
    end
    let(:expected_todo_items) do
      [{ 'completed' => false, 'description' => 'Item Description',
         'id' => 1, 'name' => 'Test Item', 'todo_list_id' => 1 }]
    end

    it 'returns ok status' do
      get :index, params: { todo_list_id: todo_list.id }, format: :json

      expect(response.status).to eq(200)
    end

    it 'returns all todo items' do
      get :index, params: { todo_list_id: todo_list.id }, format: :json

      expect(JSON.parse(response.body)).to eq(expected_todo_items)
    end
  end

  describe 'GET show' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }
    let!(:todo_item) do
      todo_list.todo_items.create(name: 'Test Item', description: 'Item Description', completed: false)
    end
    let(:expected_todo_item) do
      { 'todo_item' => { 'completed' => false,
                         'description' => 'Item Description', 'id' => 1,
                         'name' => 'Test Item', 'todo_list_id' => 1 } }
    end

    it 'returns ok status' do
      get :show, params: { todo_list_id: todo_list.id, id: todo_item.id }, format: :json

      expect(response.status).to eq(200)
    end

    it 'returns the correct todo item' do
      get :show, params: { todo_list_id: todo_list.id, id: todo_item.id }, format: :json

      expect(JSON.parse(response.body)).to eq(expected_todo_item)
    end
  end

  describe 'PUT update' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }
    let!(:todo_item) do
      todo_list.todo_items.create(name: 'Test Item', description: 'Item Description', completed: false)
    end

    context 'when params is valid' do
      let(:params) do
        { 'todo_list_id' => todo_list.id,
          'id' => todo_item.id,
          'todo_item' =>
          { 'name' => 'Updated Test Item',
            'description' => 'Updated Item Description',
            'completed' => true } }
      end
      let(:expected_todo_item) do
        { 'todo_item' => { 'completed' => true,
                           'description' => 'Updated Item Description', 'id' => 1,
                           'name' => 'Updated Test Item', 'todo_list_id' => 1 } }
      end

      it 'returns ok status' do
        put :update, params: params, format: :json

        expect(response.status).to eq(200)
      end

      it 'returns the updated todo item' do
        put :update, params: params, format: :json

        expect(JSON.parse(response.body)).to eq(expected_todo_item)
      end
    end

    context 'when params is invalid' do
      let(:params) do
        { 'todo_list_id' => todo_list.id,
          'id' => todo_item.id,
          'todo_item' =>
          { 'name' => 12_345,
            'description' => 'Updated Item Description',
            'completed' => true,
            'todo_list_id' => nil } }
      end

      it 'returns unprocessable entity status' do
        put :update, params: params, format: :json

        expect(response.status).to eq(422)
      end

      it 'returns the error in response' do
        put :update, params: params, format: :json

        expect(JSON.parse(response.body)).to eq({ 'todo_list' => ['must exist'],
                                                  'todo_list_id' => ["can't be blank"] })
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }
    let!(:todo_item) do
      todo_list.todo_items.create(name: 'Test Item', description: 'Item Description', completed: false)
    end

    it 'returns no content status' do
      delete :destroy, params: { todo_list_id: todo_list.id, id: todo_item.id }, format: :json

      expect(response.status).to eq(204)
    end

    it 'removes the todo item' do
      delete :destroy, params: { todo_list_id: todo_list.id, id: todo_item.id }, format: :json

      expect(TodoItem.find_by(id: todo_item.id)).to be_nil
    end
  end
end
