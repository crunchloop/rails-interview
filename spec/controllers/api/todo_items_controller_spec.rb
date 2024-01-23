require 'rails_helper'

describe Api::TodoItemsController do
  render_views

  let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

  describe 'GET index' do
    let!(:todo_item) { todo_list.todo_items.create(title: 'Create a new project') }

    context 'when format is JSON' do
      it 'returns a success code' do
        get :index, format: :json, params: { todo_list_id: todo_list.id }

        expect(response.status).to eq(200)
      end

      it 'includes todo item records' do
        get :index, format: :json, params: { todo_list_id: todo_list.id }

        todo_items = JSON.parse(response.body)

        aggregate_failures 'includes the id and title' do
          expect(todo_items.count).to eq(1)
          expect(todo_items[0].keys).to match_array(["completed", "created_at", "description", "id", "title", "updated_at"])
          expect(todo_items[0]['id']).to eq(todo_item.id)
          expect(todo_items[0]['title']).to eq(todo_item.title)
          expect(todo_items[0]['description']).to eq(todo_item.description)
        end
      end
    end
  end

  describe 'POST create' do
    context 'when format is JSON' do
      context 'when params are valid' do
        it 'creates a correct todo item record' do
          count = TodoItem.count

          post :create, format: :json, params: { todo_list_id: todo_list.id, todo_item: { title: 'Test todo item', description: 'Test description' } }
          todo_item = TodoItem.last

          todo_item_created = JSON.parse(response.body)

          aggregate_failures 'it increases the count on 1, and the title mathces the response' do
            expect(response.status).to eq(200)
            expect(TodoItem.count).to eq(count + 1)
            expect(todo_item_created['title']).to eq(todo_item.title)
            expect(todo_item_created['description']).to eq(todo_item.description)
          end
        end
      end

      context 'when params are invalid' do
        it 'raises an error and do not create the record' do
          post :create, format: :json, params: { todo_list_id: todo_list.id, todo_item: { title: '' } }

          result = JSON.parse(response.body)

          aggregate_failures 'it does not create the record and returns an error' do
            expect(response.status).to eq(422)
            expect(TodoItem.count).to eq(0)
            expect(result['errors']).to eq(["Title can't be blank"])
          end
        end
      end
    end

    describe 'PUT update' do
      let!(:todo_item) { todo_list.todo_items.create(title: 'Create a new project', description: 'Item despcirption') }

      context 'when format is JSON' do
        context 'when params are valid' do
          it 'updates a correct todo item record' do
            put :update, format: :json, params: { todo_list_id: todo_list.id, id: todo_item.id, todo_item: { title: 'Test todo item', description: 'Item description updated' } }
            todo_item.reload

            todo_item_response = JSON.parse(response.body)

            aggregate_failures 'it updates the record and returns the updated title' do
              expect(response.status).to eq(200)
              expect(todo_item.title).to eq('Test todo item')
              expect(todo_item_response['title']).to eq('Test todo item')
              expect(todo_item_response['description']).to eq('Item description updated')
            end
          end
        end

        context 'when params are invalid' do
          it 'raises an error and do not update the record' do
            put :update, format: :json, params: { todo_list_id: todo_list.id, id: todo_item.id, todo_item: { title: '' } }

            todo_item.reload

            result = JSON.parse(response.body)

            aggregate_failures 'it does not update the record and returns an error' do
              expect(response.status).to eq(422)
              expect(todo_item.title).to eq('Create a new project')
              expect(result['errors']).to eq(["Title can't be blank"])
            end
          end
        end

        context 'when todo list is not found' do
          it 'raises an error' do
            put :update, format: :json, params: { todo_list_id: TodoList.last.id + 1000, id: todo_item.id, todo_item: { title: 'Test todo item' } }

            result = JSON.parse(response.body)

            expect(response.status).to eq(404)
            expect(result['errors']).to eq('TodoList not found')
          end
        end

        context 'when todo item is not found' do
          it 'raises an error' do
            put :update, format: :json, params: { todo_list_id: todo_list.id, id: TodoItem.last.id + 1000, todo_item: { title: 'Test todo item' } }

            result = JSON.parse(response.body)

            expect(response.status).to eq(404)
            expect(result['errors']).to eq('TodoItem not found')
          end
        end
      end
    end

    describe 'DELETE destroy' do
      let!(:todo_item) { todo_list.todo_items.create(title: 'Create a new project', description: 'Item despcirption') }

      context 'when format is JSON' do
        it 'deletes the todo item record' do
          count = TodoItem.count

          delete :destroy, format: :json, params: { todo_list_id: todo_list.id, id: todo_item.id }

          aggregate_failures 'it deletes the record and returns a success code' do
            expect(response.status).to eq(204)
            expect(TodoItem.count).to eq(count - 1)
            expect(TodoItem.find_by(id: todo_item.id)).to be_nil
          end
        end

        context 'when todo list is not found' do
          it 'raises an error' do
            delete :destroy, format: :json, params: { todo_list_id: TodoList.last.id + 1000, id: todo_item.id }

            result = JSON.parse(response.body)

            expect(response.status).to eq(404)
            expect(result['errors']).to eq('TodoList not found')
          end
        end

        context 'when todo item is not found' do
          it 'raises an error' do
            delete :destroy, format: :json, params: { todo_list_id: todo_list.id, id: TodoItem.last.id + 1000 }

            result = JSON.parse(response.body)

            expect(response.status).to eq(404)
            expect(result['errors']).to eq('TodoItem not found')
          end
        end
      end
    end
  end
end
