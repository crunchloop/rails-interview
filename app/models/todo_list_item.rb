class TodoListItem < ApplicationRecord
  belongs_to :todo_list

  enum status: { draft: 0, active: 1, closed: 2 }

  after_create_commit :broadcast_create
  after_update_commit :broadcast_update
  after_destroy_commit :broadcast_destroy

  private

  def broadcast_create
    Turbo::StreamsChannel.broadcast_prepend_to(
      todo_list.user,
      "todo_lists",
      target: "todo_list_items_#{todo_list_id}",
      partial: "todo_lists/todo_list_item",
      locals: { todo_list: todo_list, item: self }
    )
  end

  def broadcast_update
    Turbo::StreamsChannel.broadcast_replace_to(
      todo_list.user,
      "todo_lists",
      target: "todo_list_item_#{id}",
      partial: "todo_lists/todo_list_item",
      locals: { todo_list: todo_list, item: self }
    )
  end

  def broadcast_destroy
     Turbo::StreamsChannel.broadcast_remove_to(
      todo_list.user,
      "todo_lists",
      target: "todo_list_item_#{id}"
    )
  end
end
