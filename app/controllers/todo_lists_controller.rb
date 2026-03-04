class TodoListsController < ApplicationController
  before_action :set_todo_list, only: %i[show edit update destroy]

  # GET /todolists
  def index
    @todo_lists = TodoList.all
    @todo_list = TodoList.new
  end

  # GET /todolists/:id
  def show
    @todo_item = TodoItem.new
  end

  # GET /todolists/new
  def new
    @todo_list = TodoList.new
  end

  # POST /todolists
  def create
    @todo_list = TodoList.new(todo_list_params)

    if @todo_list.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to todo_lists_path }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /todolists/:id/edit
  def edit; end

  # PATCH /todolists/:id
  def update
    if @todo_list.update(todo_list_params)
      redirect_to todo_lists_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /todolists/:id
  def destroy
    @todo_list.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@todo_list) }
      format.html { redirect_to todo_lists_path }
    end
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:id])
  end

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end
end
