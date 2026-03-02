class TodoItemSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :start_date, :end_date, :state, :todo_list_id
end
