# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TodoListsController, type: :controller do
  render_views

  let!(:todo_list) { create(:todo_list) }
  let(:valid_attributes) { attributes_for(:todo_list) }
  let(:invalid_attributes) { { name: '' } }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET #show' do
    context 'with valid params' do
      let(:params) { { id: todo_list.id } }

      it 'returns a success response' do
        get :show, params: params
        expect(response).to be_successful
      end

      it 'renders the show template' do
        get :show, params: params
        expect(response).to render_template('show')
      end
    end

    context 'with invalid params' do
      let(:params) { { id: 158 } }

      it 'returns a not found response' do
        get :show, params: params
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Record not found' })
      end
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      get :edit, params: { id: todo_list.to_param }
      expect(response).to be_successful
    end

    it 'renders the edit template' do
      get :edit, params: { id: todo_list.to_param }
      expect(response).to render_template('edit')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new TodoList' do
        expect do
          post :create, params: { todo_list: valid_attributes }
        end.to change(TodoList, :count).by(1)
      end

      it 'redirects to the todo lists index' do
        post :create, params: { todo_list: valid_attributes }
        expect(response).to redirect_to(todo_lists_path)
      end
    end

    context 'with invalid params' do
      it 'renders the index template' do
        post :create, params: { todo_list: invalid_attributes }
        expect(response).to render_template('index')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { name: 'Updated Todo List' } }

      it 'updates the requested todo list' do
        put :update, params: { id: todo_list.to_param, todo_list: new_attributes }
        todo_list.reload
        expect(todo_list.name).to eq('Updated Todo List')
      end

      it 'redirects to the todo lists index' do
        put :update, params: { id: todo_list.to_param, todo_list: new_attributes }
        expect(response).to redirect_to(todo_lists_path)
      end
    end

    context 'with invalid params' do
      it 'renders the edit template' do
        put :update, params: { id: todo_list.to_param, todo_list: invalid_attributes }
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested todo list' do
      expect do
        delete :destroy, params: { id: todo_list.to_param }
      end.to change(TodoList, :count).by(-1)
    end

    it 'redirects to the todo lists index' do
      delete :destroy, params: { id: todo_list.to_param }
      expect(response).to redirect_to(todo_lists_path)
    end
  end
end
