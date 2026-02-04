class TodoListsController < ApplicationController
  before_action :set_todo_lists, only: %i[ show new edit ]
  before_action :set_todo_list, only: %i[ edit update destroy complete_all ]

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

  def edit
  end

  def update
    @todo_list.update!(todo_list_params)
    redirect_to todo_list_url(@todo_list)
  end

  def destroy
    @todo_list.destroy
    redirect_to root_url, status: :see_other
  end

  def complete_all
    CompleteAllTodoItemsJob.perform_later(@todo_list)
  end

  private

  def todo_list_params
    params.require(:todo_list).permit(%i[ name description ])
  end

  def set_todo_lists
    @todo_lists = TodoList.all
  end

  def set_todo_list
    @todo_list = TodoList.find(params[:id])
  end
end
