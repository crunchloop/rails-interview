json.array! @todo_lists do |todo_list|
  json.partial! 'api/todo_lists/todo_list_info', todo_list: todo_list
end
