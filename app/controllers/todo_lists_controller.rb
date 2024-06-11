class TodoListsController < ApplicationController
  before_action :get_todo_list, only: %i[destroy show update edit]

  def create
    @todo_list = TodoList.new(create_params)
    if @todo_list.save
      respond_to do |format|
        format.html { redirect_to todo_lists_path }
        format.turbo_stream { flash.now[:notice] = "TodoList was successfully created." }
      end
    else
      render :new
    end
  end

  def destroy
    @todo_list.destroy
    respond_to do |format|
      format.html { redirect_to todo_lists_path }
      format.turbo_stream { flash.now[:notice] = "TodoList was successfully destroyed." }
    end
  end

  def edit
  end

  def index
    @todo_lists = TodoList.all
  end

  def new
    @todo_list = TodoList.new
  end

  def show
  end

  def update
    @todo_list.update(update_params)
    if @todo_list.save
      respond_to do |format|
        format.html { redirect_to todo_lists_path}
        format.turbo_stream { flash.now[:notice] = "TodoList was successfully updated." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def create_params
    params.require(:todo_list).permit(:name)
  end

  def get_todo_list
    @todo_list = TodoList.find(params[:id])
  end

  def update_params
    params.require(:todo_list).permit(:name)
  end
end
