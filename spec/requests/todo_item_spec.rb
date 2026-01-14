require 'rails_helper'

RSpec.describe 'TodoItems', type: :request do
  let(:todo_list) { create(:todo_list) }

  describe 'GET /todolists/:todo_list_id/todo_items/new' do
    it 'returns http success' do
      get new_todo_list_todo_item_path(todo_list)

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST /todolists/:todo_list_id/todo_items' do
    context 'with valid params' do
      let(:valid_params) do
        {
          todo_item: {
            title: 'Buy milk',
            description: '2 liters'
          }
        }
      end

      it 'creates a todo item' do
        expect do
          post todo_list_todo_items_path(todo_list), params: valid_params
        end.to change(TodoItem, :count).by(1)
      end

      it 'redirects to todo item show page' do
        post todo_list_todo_items_path(todo_list), params: valid_params

        todo_item = TodoItem.last
        expect(response).to redirect_to([todo_list, todo_item])
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          todo_item: {
            title: ''
          }
        }
      end

      it 'does not create a todo item' do
        expect do
          post todo_list_todo_items_path(todo_list), params: invalid_params
        end.not_to change(TodoItem, :count)
      end

      it 'returns unprocessable entity' do
        post todo_list_todo_items_path(todo_list), params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET /todolists/:todo_list_id/todo_items/:id' do
    let(:todo_item) { create(:todo_item, todo_list: todo_list) }

    it 'returns http success' do
      get todo_list_todo_item_path(todo_list, todo_item)

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:show)
    end
  end

  describe 'GET /todolists/:todo_list_id/todo_items/:id/edit' do
    let(:todo_item) { create(:todo_item, todo_list: todo_list) }

    it 'returns http success' do
      get edit_todo_list_todo_item_path(todo_list, todo_item)

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH /todolists/:todo_list_id/todo_items/:id' do
    let(:todo_item) { create(:todo_item, todo_list: todo_list) }

    context 'with valid params' do
      it 'updates the todo item' do
        patch todo_list_todo_item_path(todo_list, todo_item), params: {
          todo_item: { title: 'Updated title' }
        }

        expect(todo_item.reload.title).to eq('Updated title')
        expect(response).to redirect_to([todo_list, todo_item])
      end
    end

    context 'with invalid params' do
      it 'does not update the todo item' do
        patch todo_list_todo_item_path(todo_list, todo_item), params: {
          todo_item: { title: '' }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE /todolists/:todo_list_id/todo_items/:id' do
    let!(:todo_item) { create(:todo_item, todo_list: todo_list) }

    it 'deletes the todo item' do
      expect do
        delete todo_list_todo_item_path(todo_list, todo_item)
      end.to change(TodoItem, :count).by(-1)
    end

    it 'redirects to todo list' do
      delete todo_list_todo_item_path(todo_list, todo_item)

      expect(response).to redirect_to(todo_list)
    end
  end

  describe 'POST /todolists/:todo_list_id/todo_items/:id/mark_as_complete' do
    let(:todo_item) do
      create(:todo_item, todo_list: todo_list, complete: false)
    end

    it 'marks the todo item as complete' do
      patch mark_as_complete_todo_list_todo_item_path(todo_list, todo_item)

      expect(todo_item.reload.complete).to be true
      expect(response).to redirect_to(todo_list)
    end
  end
end
