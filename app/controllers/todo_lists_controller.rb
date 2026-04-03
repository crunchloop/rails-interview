class TodoListsController < ApplicationController
  include TodoListActions

  before_action :set_todo_list, only: %i[ edit update destroy ]

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

  # GET /todolists/edit
  def edit
  end

  # POST /todolists
  def create
    if create_todo_list
      redirect_to todo_lists_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PUT /todolists/:id
  def update
    if update_todo_list
      redirect_to todo_lists_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # POST /api/todolists/:id/complete_all
  def complete_all
    CompleteAllTodoItemsJob.perform_later(params[:id])

    redirect_to todo_lists_path, notice: "All items in the list will be marked as completed shortly."
  end

  # DELETE /todolists/:id
  def destroy
    destroy_todo_list!
    redirect_to todo_lists_path
  end
end
