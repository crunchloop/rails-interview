ActiveAdmin.register TodoItem do
  permit_params :title, :description, :todo_list_id, :completed
  
end
