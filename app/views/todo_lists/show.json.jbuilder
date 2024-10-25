# app/views/todo_lists/show.json.jbuilder

json.id @todo_list.id
json.name @todo_list.name
json.total_items @todo_list.todo_items.count

json.todo_items @todo_list.todo_items do |item|
  json.id item.id
  json.name item.name
  json.is_completed item.is_completed
  json.completion_status item.is_completed ? "Completed" : "Incomplete"
end
