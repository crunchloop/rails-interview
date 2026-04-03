# frozen_string_literal: true

TodoList.create(name: 'Setup Rails Application')
TodoList.create(name: 'Setup Docker PG database')
TodoList.create(name: 'Create todo_lists table')
TodoList.create(name: 'Create TodoList model')
TodoList.create(name: 'Create TodoList controller')

TodoItem.create(description: 'Create index action', todo_list_id: 1)
TodoItem.create(description: 'Create show action', todo_list_id: 1)
TodoItem.create(description: 'Create create action', todo_list_id: 1)
TodoItem.create(description: 'Create update action', todo_list_id: 1)
TodoItem.create(description: 'Create destroy action', todo_list_id: 1)