class TodoListsController < ApplicationController
  before_action :set_todo_lists # ToDO: add 'only' later

  def show
    @todo_list = TodoList.includes(:todo_items).find(params[:id])
    @todo_items = @todo_list.todo_items
    @todo_item = TodoItem.new

    @pending_todo_items = @todo_items.pending
    @completed_todo_items = @todo_items.completed
  end

  def new
    @todo_list = TodoList.new
  end

  def create
    todo_list = TodoList.create!(todo_list_params)
    redirect_to todo_list_url(todo_list)
  end

  private

  def todo_list_params
    params.require(:todo_list).permit(%i[ name description ])
  end

  def set_todo_lists
    @todo_lists = TodoList.all
  end
end
