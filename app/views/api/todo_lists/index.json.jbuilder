json.array! @todo_lists do |todo_list|
  json.extract! todo_list, :id, :name
  json.todo_list_items todo_list.todo_list_items.order(:created_at) do |item|
    json.extract! item, :id, :todo_list_id, :description, :status, :created_at, :updated_at
  end
end