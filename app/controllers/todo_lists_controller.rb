class TodoListsController < ApplicationController
  # GET /todolists
  def index
    @todo_lists = current_user.todo_lists.includes(:todo_list_items).order(:id)

    respond_to :html
  end

  # GET /todolists/new
  def new
    @todo_list = current_user.todo_lists.new

    respond_to :html
  end

  # POST /todolists
  def create
    todo_list = current_user.todo_lists.create!(todo_list_params)
    redirect_to todo_lists_path, notice: "Created “#{todo_list.name}”."
  end

  private

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end
end
