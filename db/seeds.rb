# Crear una TodoList
todo_list = TodoList.create!(name: "TodoList with 1000 TodoItems")

# Crear 1000 TodoItems para esa TodoList
1000.times do |i|
  TodoItem.create!(
    name: "TodoItem #{i + 1}",
    description: Faker::Lorem.sentence(word_count: 10),
    is_complete: [true, false].sample,
    todo_list: todo_list
  )
end

puts "Seed completed: Created 1 TodoList with 1000 TodoItems."
