require 'rails_helper'

describe Api::TodoListItemsController do
  describe 'POST create' do
    let!(:todo_list) { TodoList.create!(name: 'Groceries') }

    it 'creates a todo list item and returns 201' do
      post :create,
           params: {
             todo_list_id: todo_list.id,
             todo_list_item: {
               description: 'Buy milk',
               status: 'active'
             }
           },
           format: :json

      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)

      aggregate_failures do
        expect(body['id']).to be_present
        expect(body['todo_list_id']).to eq(todo_list.id)
        expect(body['description']).to eq('Buy milk')
        expect(body['status']).to eq('active')
      end
    end
  end

  describe 'PATCH update' do
    let!(:todo_list) { TodoList.create!(name: 'Groceries') }
    let!(:item) do
      todo_list.todo_list_items.create!(
        description: 'Buy milk',
        status: :active
      )
    end

    it 'updates a todo list item and returns 200' do
      patch :update,
            params: {
              todo_list_id: todo_list.id,
              id: item.id,
              todo_list_item: {
                description: 'Buy almond milk',
                status: 'closed'
              }
            },
            format: :json

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      aggregate_failures do
        expect(body['id']).to eq(item.id)
        expect(body['todo_list_id']).to eq(todo_list.id)
        expect(body['description']).to eq('Buy almond milk')
        expect(body['status']).to eq('closed')
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_list) { TodoList.create!(name: 'Groceries') }
    let!(:item) do
      todo_list.todo_list_items.create!(
        description: 'Buy milk',
        status: :active
      )
    end

    it 'destroys the todo list item and returns 204' do
      expect do
        delete :destroy,
               params: {
                 todo_list_id: todo_list.id,
                 id: item.id
               },
               format: :json
      end.to change { todo_list.todo_list_items.count }.by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end

