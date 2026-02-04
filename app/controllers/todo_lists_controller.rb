class TodoListsController < ApplicationController
  before_action :set_todo_lists # ToDO: add 'only' later

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

  private

  def set_todo_lists
    @todo_lists = TodoList.all
  end
end
