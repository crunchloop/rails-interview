return unless Rails.env.development?

TodoList.create(name: 'Setup Rails Application')
TodoList.create(name: 'Setup Docker PG database')
TodoList.create(name: 'Create todo_lists table')
TodoList.create(name: 'Create TodoList model')
TodoList.create(name: 'Create TodoList controller')
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
