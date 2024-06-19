# frozen_string_literal: true

class TodoItemsController < BaseController
  before_action :load_todo_list
  before_action :load_todo_item, only: %i[show edit update destroy]

  def index
    @todo_items = @todo_list.todo_items
  end

  def show; end

  def new
    @todo_item = @todo_list.todo_items.build
  end

  def create
    @todo_item = @todo_list.todo_items.build(todo_item_params)
    save_todo_item(:new, 'Todo item was successfully created.')
  end

  def edit; end

  def update
    @todo_item.update(todo_item_params)
    save_todo_item(:edit, 'Todo item was successfully updated.')
  end

  def destroy
    @todo_item.destroy
    respond_to do |format|
      format.html { redirect_to todo_list_todo_items_path(@todo_list), notice: 'Todo item was successfully destroyed.' }
      format.turbo_stream
    end
  end

  private

  def load_todo_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def load_todo_item
    @todo_item = @todo_list.todo_items.find(params[:id])
  end

  def todo_item_params
    params.require(:todo_item).permit(:name, :description, :completed)
  end

  def save_todo_item(action, message)
    if @todo_item.save
      handle_successful_save(message)
    else
      handle_failed_save(action)
    end
  end

  def handle_successful_save(message)
    respond_to do |format|
      format.html { redirect_to todo_list_todo_items_path(@todo_list), notice: message }
      format.turbo_stream
    end
  end

  def handle_failed_save(action)
    respond_to do |format|
      format.html { render action }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(@todo_item, partial: 'form', locals: { todo_item: @todo_item })
      end
    end
  end
end
