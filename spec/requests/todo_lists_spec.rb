require 'swagger_helper'

RSpec.describe 'TodoLists API', type: :request do
  path '/todo_lists' do
    get 'Retrieve all todo lists' do
      tags 'TodoLists'
      produces 'application/json'
      response '200', 'Todo lists found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              total_items: { type: :integer },
              todo_items: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    name: { type: :string },
                    is_completed: { type: :boolean },
                    completion_status: { type: :string }
                  }
                }
              }
            }
          }

        let!(:todo_lists) { create_list(:todo_list, 3, :with_todo_items) }
        run_test!
      end

    end

    post 'Create a new todo list' do
      tags 'TodoLists'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :todo_list, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          todo_items_attributes: {
            type: :array,
            items: {
              type: :object,
              properties: {
                name: { type: :string },
                description: { type: :string },
                is_complete: { type: :boolean }
              }
            }
          }
        },
        required: ['name']
      }

      response '201', 'TodoList created' do
        let(:todo_list) { { name: 'New list', todo_items_attributes: [{ name: 'Task 1', description: 'Task 1 description', is_complete: false }] } }
        run_test!
      end

    end
  end

  path '/todo_lists/{id}' do
    get 'Retrieve a specific todo list' do
      tags 'TodoLists'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      response '200', 'Todo list found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            total_items: { type: :integer },
            todo_items: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  is_completed: { type: :boolean },
                  completion_status: { type: :string }
                }
              }
            }
          }

        let(:id) { TodoList.create(name: 'List with items').id }
        run_test!
      end

      response '404', 'Todo list not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    delete 'Delete a todo list' do
      tags 'TodoLists'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      response '200', 'Todo list deleted' do
        let(:id) { TodoList.create(name: 'List to delete').id }
        run_test!
      end

      response '404', 'Todo list not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/todo_lists/{id}/complete' do
    post 'Complete todo items in a list' do
      tags 'TodoLists'
      produces 'application/json'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :integer
      parameter name: :selected_items, in: :body, schema: {
        type: :object,
        properties: {
          selected_items: {
            type: :array,
            items: { type: :integer }
          }
        },
        required: ['selected_items']
      }

      response '422', 'Unprocessable entity (No items selected)' do
        let(:id) { TodoList.create(name: 'List without items').id }
        let(:selected_items) { { selected_items: [] } }
        run_test!
      end

    end
  end

  path '/todo_lists/generate_lists' do
    post 'Generate random todo lists' do
      tags 'TodoLists'
      produces 'application/json'

      response '200', 'Todo lists generated' do
        run_test!
      end
    end
  end
end
