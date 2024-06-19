# frozen_string_literal: true

require 'rails_helper'

describe Api::TodoListsController do
  render_views

  describe 'GET index' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    context 'when format is HTML' do
      it 'raises a routing error' do
        expect do
          get :index
        end.to raise_error(ActionController::RoutingError, 'Not supported format')
      end
    end

    context 'when format is JSON' do
      it 'returns a success code' do
        get :index, format: :json

        expect(response.status).to eq(200)
      end

      it 'includes todo list records' do
        get :index, format: :json

        expect(JSON.parse(response.body))
          .to eq([{ 'id' => 1, 'name' => 'Setup RoR project' }])
      end
    end
  end

  describe 'POST create' do
    context 'when params is valid' do
      let(:params) do
        { 'todo_list' => { 'name' => 'New List' } }
      end
      let(:todo_list_params) do
        { 'todo_list' => { 'id' => 1, 'name' => 'New List' } }
      end

      it 'returns created code' do
        post :create, params: params, format: :json

        expect(response.status).to eq(201)
      end

      it 'returns correct todo list' do
        post :create, params: params, format: :json

        expect(JSON.parse(response.body)).to eq(todo_list_params)
      end
    end

    context 'when params is invalid' do
      let(:params) do
        { 'todo_list' => { 'name' => '' } }
      end

      it 'returns unprocessable entity code' do
        post :create, params: params, format: :json

        expect(response.status).to eq(422)
      end

      it 'returns error in response' do
        post :create, params: params, format: :json

        expect(JSON.parse(response.body)).to eq({ 'name' => ["can't be blank"] })
      end
    end
  end

  describe 'GET show' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }
    let(:expected_response) { { 'todo_list' => { 'id' => 1, 'name' => 'Setup RoR project' } } }

    it 'returns ok status' do
      get :show, params: { id: todo_list.id }, format: :json

      expect(response.status).to eq(200)
    end

    it 'returns the correct todo list' do
      get :show, params: { id: todo_list.id }, format: :json

      expect(JSON.parse(response.body)).to eq(expected_response)
    end
  end

  describe 'PUT update' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    context 'when params is valid' do
      let(:params) do
        { 'id' => todo_list.id, 'todo_list' => { 'name' => 'Updated List' } }
      end
      let(:expected_response) { { 'todo_list' => { 'id' => 1, 'name' => 'Updated List' } } }

      it 'returns ok status' do
        put :update, params: params, format: :json

        expect(response.status).to eq(200)
      end

      it 'returns the updated todo list' do
        put :update, params: params, format: :json

        expect(JSON.parse(response.body)).to eq(expected_response)
      end
    end

    context 'when params is invalid' do
      let(:params) do
        { 'id' => todo_list.id, 'todo_list' => { 'name' => '' } }
      end

      it 'returns unprocessable entity code' do
        put :update, params: params, format: :json

        expect(response.status).to eq(422)
      end

      it 'returns error in response' do
        put :update, params: params, format: :json

        expect(JSON.parse(response.body)).to eq({ 'name' => ["can't be blank"] })
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    it 'returns no content status' do
      delete :destroy, params: { id: todo_list.id }, format: :json

      expect(response.status).to eq(204)
    end

    it 'removes the todo list' do
      delete :destroy, params: { id: todo_list.id }, format: :json

      expect(TodoList.find_by(id: todo_list.id)).to be_nil
    end
  end
end
