class TodoItemsController < ApplicationController
  before_action :get_todo_list
  before_action :get_todo_item, only: %i[destroy show update edit]

  def create
    @todo_item = TodoItem.new(create_params.merge(todo_list_id: @todo_list.id))
    if @todo_item.save
      respond_to do |format|
        format.html { redirect_to todo_list_path(@todo_list) }
        format.turbo_stream { flash.now[:notice] = "TodoItem was successfully created." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @todo_item.destroy
    respond_to do |format|
      format.html { redirect_to todo_list_path(@todo_list)}
      format.turbo_stream { flash.now[:notice] = "TodoItem was successfully destroyed." }
    end
  end

  def edit
  end

  def new
    @todo_item = TodoItem.new
  end

  def show
  end

  def update
    if @todo_item.update(update_params)
      respond_to do |format|
        format.html { redirect_to todo_list_path(@todo_list)}
        format.turbo_stream { flash.now[:notice] = "TodoItem was successfully updated." }
      end
    else
      render :edit
    end
  end

  private

  def create_params
    params.require(:todo_item).permit(:name, :done)
  end

  def get_todo_item
    @todo_item = @todo_list.todo_items.find(params[:id])
  end

  def get_todo_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def update_params
    params.require(:todo_item).permit(:name, :done)
  end
end
