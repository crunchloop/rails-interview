class TodoListsController < ApplicationController
  def show
    @todo_list = TodoList.includes(:todo_items).find(params[:id])
    @todo_items = @todo_list.todo_items
    @todo_item = @todo_list.todo_items.build
  end

  # GET /todolists
  def index
    @todo_lists = TodoList.all

    respond_to :html
  end

  # GET /todolists/new
  def new
    @todo_list = TodoList.new

    respond_to :html
  end
end
