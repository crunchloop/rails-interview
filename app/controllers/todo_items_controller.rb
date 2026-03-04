class TodoItemsController < ApplicationController
  before_action :set_todo_list
  before_action :set_todo_item, only: %i[edit update destroy]

  # GET /todolists/:todo_list_id/items/new
  def new
    @todo_item = @todo_list.todo_items.new
  end

  # POST /todolists/:todo_list_id/items
  def create
    @todo_item = @todo_list.todo_items.new(todo_item_params)

    if @todo_item.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to todo_list_path(@todo_list) }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /todolists/:todo_list_id/items/:id/edit
  def edit; end

  # PATCH /todolists/:todo_list_id/items/:id
  def update
    if @todo_item.update(todo_item_params)
      redirect_to todo_list_path(@todo_list)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /todolists/:todo_list_id/items/:id
  def destroy
    @todo_item.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@todo_item) }
      format.html { redirect_to todo_list_path(@todo_list) }
    end
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def set_todo_item
    @todo_item = @todo_list.todo_items.find(params[:id])
  end

  def todo_item_params
    params.require(:todo_item).permit(:title, :description, :start_date, :end_date, :state)
  end
end
