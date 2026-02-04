class TodoItemsController < ApplicationController
  before_action :set_todo_list, only: %i[ create destroy ]
  before_action :set_todo_item, only: %i[ destroy ]

  def create
    @todo_list.todo_items.create!(todo_item_params)
    redirect_to @todo_list
  end

  def destroy
    @todo_item.destroy
    redirect_to @todo_list, status: :see_other
  end

  private

  def todo_item_params
    params.require(:todo_item).permit(%i[ name ])
  end

  def set_todo_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def set_todo_item
    @todo_item = @todo_list.todo_items.find(params[:id])
  end
end
