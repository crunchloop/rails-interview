# frozen_string_literal: true

# spec/controllers/todo_items_controller_spec.rb
require 'rails_helper'

RSpec.describe TodoItemsController, type: :controller do
  render_views

  let!(:todo_item) { create(:todo_item) }
  let(:todo_list) { todo_item.todo_list }
  let(:valid_attributes) { attributes_for(:todo_item) }
  let(:invalid_attributes) { { name: '' } }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: { todo_list_id: todo_list.id }
      expect(response).to be_successful
    end

    it 'renders the index template' do
      get :index, params: { todo_list_id: todo_list.id }
      expect(response).to render_template('index')
    end
  end

  describe 'GET #show' do
    context 'with valid params' do
      let(:params) { { todo_list_id: todo_list.id, id: todo_item.id } }

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
      let(:params) { { todo_list_id: todo_list.id, id: 158 } }

      it 'returns a not found response' do
        get :show, params: params
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      get :edit, params: { todo_list_id: todo_list.id, id: todo_item.to_param }
      expect(response).to be_successful
    end

    it 'renders the edit template' do
      get :edit, params: { todo_list_id: todo_list.id, id: todo_item.to_param }
      expect(response).to render_template('edit')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new TodoItem' do
        expect do
          post :create, params: { todo_list_id: todo_list.id, todo_item: valid_attributes }
        end.to change(TodoItem, :count).by(1)
      end

      it 'redirects to the todo items index' do
        post :create, params: { todo_list_id: todo_list.id, todo_item: valid_attributes }
        expect(response).to redirect_to(todo_list_todo_items_path(todo_list))
      end
    end

    context 'with invalid params' do
      it 'renders the new template' do
        post :create, params: { todo_list_id: todo_list.id, todo_item: invalid_attributes }
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { name: 'Updated Todo Item' } }

      it 'updates the requested todo item' do
        put :update, params: { todo_list_id: todo_list.id, id: todo_item.to_param, todo_item: new_attributes }
        todo_item.reload
        expect(todo_item.name).to eq('Updated Todo Item')
      end

      it 'redirects to the todo items index' do
        put :update, params: { todo_list_id: todo_list.id, id: todo_item.to_param, todo_item: new_attributes }
        expect(response).to redirect_to(todo_list_todo_items_path(todo_list))
      end
    end

    context 'with invalid params' do
      it 'renders the edit template' do
        put :update, params: { todo_list_id: todo_list.id, id: todo_item.to_param, todo_item: invalid_attributes }
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested todo item' do
      expect do
        delete :destroy, params: { todo_list_id: todo_list.id, id: todo_item.to_param }
      end.to change(TodoItem, :count).by(-1)
    end

    it 'redirects to the todo items index' do
      delete :destroy, params: { todo_list_id: todo_list.id, id: todo_item.to_param }
      expect(response).to redirect_to(todo_list_todo_items_path(todo_list))
    end
  end
end
