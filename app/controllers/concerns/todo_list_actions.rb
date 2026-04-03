module TodoListActions
  extend ActiveSupport::Concern

  private

  def create_todo_list
    @todo_list = TodoList.new(todo_list_params)
    @todo_list.save
  end

  def update_todo_list
    @todo_list.update(todo_list_params)
  end

  def destroy_todo_list!
    @todo_list.destroy!
  end

  def set_todo_list
    @todo_list ||= TodoList.find(params[:id])
  end

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end
end