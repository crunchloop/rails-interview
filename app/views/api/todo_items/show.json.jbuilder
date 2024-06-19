json.todo_item do
  json.id @todo_item.id
  json.name @todo_item.name
  json.description @todo_item.description
  json.completed @todo_item.completed
  json.todo_list_id @todo_item.todo_list_id
end
