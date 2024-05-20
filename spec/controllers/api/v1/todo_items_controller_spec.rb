# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::TodoItemsController do
  render_views

  describe 'GET index' do
    let!(:todo_item) { create(:todo_item) }

    before do
      get :index, params: { todo_list_id: todo_item.todo_list.id }, format: :json
      @todo_items = JSON.parse(response.body)
    end

    it 'returns a success code' do
      expect(response.status).to eq(200)
    end

    it 'returns item info' do
      aggregate_failures 'includes the id and name' do
        expect(@todo_items.count).to eq(1)
        expect(@todo_items[0].keys).to match_array(%w[id name description completed])
        expect(@todo_items[0]['id']).to eq(todo_item.id)
        expect(@todo_items[0]['name']).to eq(todo_item.name)
      end
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

    before do
      put :update, params: todo_item_params, format: :json
    end

    it 'returns a success code' do
      expect(response.status).to eq(200)
    end

    it 'updates the todo item' do
      todo_item.reload
      expect(todo_item.name).to eq(todo_item_params[:name])
      expect(todo_item.description).to eq(todo_item_params[:description])
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_item) { create(:todo_item) }

    before do
      delete :destroy, params: { todo_list_id: todo_item.todo_list_id, id: todo_item.id }, format: :json
    end

    it 'returns a no contend sucess code' do
      expect(response.status).to eq(204)
    end

    it 'deletes the todo item' do
      expect(TodoItem.count).to eq(0)
    end
  end
end
