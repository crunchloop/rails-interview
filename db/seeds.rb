# Clear DB
TodoList.delete_all
puts "❌ TodoLists removed!"

# Populate DB
10.times { FactoryBot.create(:todo_list) }
puts "✅ TodoList created!"
