module TodoItemActions
  extend ActiveSupport::Concern

  private

  def create_todo_item
    @todo_item = TodoItem.new(todo_item_params)
    @todo_item.todo_list = @todo_list
    @todo_item.save
  end

  def update_todo_item
    @todo_item.update(todo_item_params)
  end

  def destroy_todo_item!
    @todo_item.destroy!
  end

  def set_todo_list
    @todo_list ||= TodoList.find(params[:todo_list_id])
  end

  def set_todo_item
    @todo_item ||= TodoItem.find(params[:id])
  end

  def todo_item_params
    params.require(:todo_item).permit(:name, :description, :completed)
  end
end