require 'swagger_helper'

RSpec.describe 'TodoLists API', type: :request do
  
  # Index - List all TodoLists
  path '/todo_lists' do
    get('list todo_lists') do
      tags 'TodoLists'
      produces 'application/json'

      response(200, 'successful') do
        schema type: :array,  
          items: {  
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              todo_items: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    name: { type: :string },
                    description: { type: :string },
                    is_completed: { type: :boolean },
                    created_at: { type: :string, format: 'date-time' },
                    updated_at: { type: :string, format: 'date-time' }
                  },
                  required: ['id', 'name', 'is_completed']
                }
              }
            },
            required: ['id', 'name']
          }

        run_test!
      end
    end

    post('create todo_list') do
      tags 'TodoLists'
      consumes 'application/json'
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
                is_completed: { type: :boolean }
              },
              required: ['name']
            }
          }
        },
        required: ['name']
      }

      response(201, 'created') do
        let(:todo_list) { { name: 'New List', todo_items_attributes: [{ name: 'New Item' }] } }
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:todo_list) { { name: '' } }
        run_test!
      end
    end
  end

  # Show - Get a specific TodoList
  path '/todo_lists/{id}' do
    get('show todo_list') do
      tags 'TodoLists'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'ID of the TodoList'

      response(200, 'successful') do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            todo_items: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  description: { type: :string },
                  is_completed: { type: :boolean }
                },
                required: ['id', 'name']
              }
            }
          },
          required: ['id', 'name']

        let(:id) { TodoList.create(name: 'Example').id }
        run_test!
      end

      response(404, 'not found') do
        let(:id) { -1 }
        run_test!
      end
    end

    delete('delete todo_list') do
      tags 'TodoLists'
      parameter name: :id, in: :path, type: :integer, description: 'ID of the TodoList'

      response(200, 'successful') do
        let(:id) { TodoList.create(name: 'Example').id }
        run_test!
      end

      response(404, 'not found') do
        let(:id) { -1 }
        run_test!
      end
    end
  end

  # Complete - Mark a TodoList as complete
  path '/todo_lists/{id}/complete' do
    post('complete todo_list') do
      tags 'TodoLists'
      parameter name: :id, in: :path, type: :integer, description: 'ID of the TodoList'

      response(200, 'successful') do
        let(:id) { TodoList.create(name: 'Example').id }
        run_test!
      end

      response(404, 'not found') do
        let(:id) { -1 }
        run_test!
      end
    end
  end

  # Generate multiple TodoLists
  path '/todo_lists/generate_lists' do
    post('generate todo_lists') do
      tags 'TodoLists'
      response(302, 'redirect') do
        run_test!
      end
    end
  end
end
