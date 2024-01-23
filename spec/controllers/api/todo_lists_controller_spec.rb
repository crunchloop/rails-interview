require 'rails_helper'

describe Api::TodoListsController do
  render_views

  describe 'GET index' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }
    before do
      @request.env['devise.mapping'] = Devise.mappings[:admin_user]
      sign_in AdminUser.create!(email: 'test@mail.com', password: 'password')
    end

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
          expect(todo_lists[0].keys).to match_array(["completed", "created_at", "id", "name", "updated_at"])
          expect(todo_lists[0]['id']).to eq(todo_list.id)
          expect(todo_lists[0]['name']).to eq(todo_list.name)
        end
      end
    end
  end

  describe 'POST create' do
    context 'when format is JSON' do
      context 'when params are valid' do
        it 'creates a correct todo list record' do
          count = TodoList.count

          post :create, format: :json, params: { todo_list: { name: 'Test todo list' } }
          todo_list = TodoList.last

          todo_list_created = JSON.parse(response.body)

          aggregate_failures 'it increases the count on 1, and the name mathces on the response' do
            expect(response.status).to eq(200)
            expect(TodoList.count).to eq(count + 1)
            expect(todo_list_created['name']).to eq(todo_list.name)
          end
        end
      end

      context 'when params are invalid' do
        it 'raises an error and do not create the record' do
          post :create, format: :json, params: { todo_list: { name: '' } }

          result = JSON.parse(response.body)

          expect(TodoList.count).to eq(0)
          expect(result['errors']).to eq(["Name can't be blank"])
        end
      end
    end
  end

  describe 'PUT update' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    context 'when format is JSON' do
      context 'when params are valid' do
        it 'updates a correct todo list record' do
          put :update, format: :json, params: { id: todo_list.id, todo_list: { name: 'Test todo list' } }

          todo_list_updated = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(todo_list_updated['name']).to eq('Test todo list')
        end
      end

      context 'when params are invalid' do
        it 'raises an error and do not update the record' do
          put :update, format: :json, params: { id: todo_list.id, todo_list: { name: '' } }

          result = JSON.parse(response.body)

          expect(todo_list.reload.name).to eq('Setup RoR project')
          expect(result['errors']).to eq(["Name can't be blank"])
        end
      end

      context 'when todo_list isnt found' do
        it 'raises an error' do
          put :update, format: :json, params: { id: 1000, todo_list: { name: 'Test todo list' } }

          result = JSON.parse(response.body)

          expect(result['errors']).to eq('TodoList not found')
        end
      end
    end
  end

  describe 'DELETE delete' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    context 'when format is JSON' do
      it 'deletes a correct todo list record' do
        delete :destroy, format: :json, params: { id: todo_list.id }

        expect(response.status).to eq(204)
        expect(TodoList.count).to eq(0)
      end
    end
  end
end
