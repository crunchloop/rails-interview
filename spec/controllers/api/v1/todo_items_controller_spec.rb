# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::TodoItemsController do
  render_views

  describe 'GET index' do
    let!(:todo_list) { create(:todo_list) }
    let!(:todo_items) { create_list(:todo_item, 10, todo_list: todo_list) }
    let(:index_request) { get :index, params: { todo_list_id: todo_list.id }, format: :json }

    it 'returns a success code' do
      index_request

      expect(response.status).to eq(200)
    end

    it 'returns item info' do
      index_request
      todos = JSON.parse(response.body)

      aggregate_failures 'includes the id and name' do
        expect(todos.count).to eq(10)
        expect(todos[0].keys).to match_array(%w[id name description completed])
        expect(todos[0]['id']).to eq(todo_items[0].id)
        expect(todos[0]['name']).to eq(todo_items[0].name)
      end
    end

    it 'paginates the todo items' do
      get :index, params: { todo_list_id: todo_list.id, page: 1, per_page: 5 }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(5)
    end

    it 'returns the second page of todo items' do
      get :index, params: { todo_list_id: todo_list.id, page: 2, per_page: 5 }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(5)
      expect(json_response.first['id']).to eq(todo_items[5].id)
    end
  end

  describe 'POST create' do
    let!(:todo_list) { create(:todo_list) }
    let(:todo_item_params) { attributes_for(:todo_item, todo_list_id: todo_list.id) }

    before do
      post :create, params: todo_item_params, format: :json
      @todo_item = JSON.parse(response.body)
    end

    it 'returns a success code' do
      expect(response.status).to eq(201)
    end

    it 'returns new item info' do
      aggregate_failures 'includes id, name, descritpion and todo list id' do
        expect(@todo_item.keys).to match_array(%w[id todo_list_id name description completed])
        expect(@todo_item['name']).to eq(todo_item_params[:name])
        expect(@todo_item['description']).to eq(todo_item_params[:description])
      end
    end

    it 'creates a new todo item' do
      expect(TodoItem.count).to eq(1)
    end
  end

  describe 'PUT update' do
    let!(:todo_item) { create(:todo_item) }
    let(:todo_item_params) do
      { todo_list_id: todo_item.todo_list_id, id: todo_item.id, name: 'New name', description: 'New description' }
    end

    let(:update_request) do
      put :update, params: todo_item_params, format: :json
    end

    before do
      put :update, params: todo_item_params, format: :json
    end

    it 'returns a success code' do
      update_request
      expect(response.status).to eq(200)
    end

    it 'updates the todo item' do
      update_request

      todo_item.reload
      expect(todo_item.name).to eq(todo_item_params[:name])
      expect(todo_item.description).to eq(todo_item_params[:description])
    end

    it 'returns an error if the todo item is not found' do
      put :update, params: { todo_list_id: todo_item.todo_list_id, id: -1 }, format: :json

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Record not found for TodoItem' })
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_item) { create(:todo_item) }
    let(:destroy_request) do
      delete :destroy, params: { todo_list_id: todo_item.todo_list_id, id: todo_item.id }, format: :json
    end

    it 'returns a no contend sucess code' do
      destroy_request
      expect(response.status).to eq(204)
    end

    it 'deletes the todo item' do
      destroy_request
      expect(TodoItem.count).to eq(0)
    end

    it 'returns an error if the todo item is not found' do
      delete :destroy, params: { todo_list_id: todo_item.todo_list_id, id: -1 }, format: :json

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Record not found for TodoItem' })
    end
  end
end
