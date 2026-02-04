# Clear DB
TodoList.delete_all
puts "❌ TodoLists removed!"

# Populate DB
5.times { FactoryBot.create(:todo_list) }
puts "✅ TodoLists without TodoItems created!"

5.times { FactoryBot.create(:todo_list, :with_pending_todo_items) }
puts "✅ TodoLists with TodoItems created!"
