# app/views/todo_lists/index.json.jbuilder

json.array!(@todo_lists) do |todo_list|
  json.id todo_list.id
  json.name todo_list.name
  json.total_items todo_list.todo_items.count

  json.todo_items todo_list.todo_items do |item|
    json.id item.id
    json.name item.name
    json.is_complete item.is_complete
    json.completion_status item.is_complete ? "Completed" : "Incomplete"
  end
end
