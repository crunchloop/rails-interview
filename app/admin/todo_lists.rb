ActiveAdmin.register TodoList do
  permit_params :name, :completed

  show do
    attributes_table do
      row :name
      row :completed
      row :created_at
      row :updated_at
    end
    panel 'Todo Items' do
      table_for todo_list.todo_items do
        column :title
        column :description
        column :completed
        column :created_at
        column :updated_at
        # add actions to view, edit and delete todo items
        column(:actions) { |todo_item| link_to 'View', admin_todo_item_path(todo_item) }
      end
    end
  end
end
