####################
# Clear DB
TodoList.destroy_all
puts "❌ TodoLists removed!"

####################
# Populate DB
5.times { FactoryBot.create(:todo_list) }
puts "✅ Created empty TodoLists!"

5.times { FactoryBot.create(:todo_list, :with_pending_todo_items) }
puts "✅ Created TodoLists with pending TodoItems!"

2.times { FactoryBot.create(:todo_list, :with_pending_todo_items, todo_items_count: 1_000) }
puts "✅ Created TodoLists with MANY TodoItems!"
