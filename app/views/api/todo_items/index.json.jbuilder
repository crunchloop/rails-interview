json.array! @todo_items do |todo_item|
  json.partial! 'api/todo_items/todo_item_info', todo_item: todo_item
end
