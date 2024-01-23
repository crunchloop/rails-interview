class TodoItemsController < ApplicationController
  before_action :find_todo_list
  before_action :find_todo_item, only: %i[update destroy show edit]

  # @route GET /todo_lists/:todo_list_id/todo_items (todo_list_todo_items)
  def index
    @todo_items = @todo_list.todo_items

    respond_to :html
  end

  # @route GET /todo_lists/:todo_list_id/todo_items/:id (todo_list_todo_item)
  def show
    respond_to :html
  end

  # @route GET /todo_lists/:todo_list_id/todo_items/new (new_todo_list_todo_item)
  def new
    @todo_item = TodoItem.new

    respond_to :html
  end

  # @route POST /todo_lists/:todo_list_id/todo_items (todo_list_todo_items)
  def create
    @todo_item = @todo_list.todo_items.new(todo_item_params)

    respond_to do |format|
      if @todo_item.save
        format.html { redirect_to todo_list_path(@todo_list), notice: 'Todo item was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  def edit
    respond_to :html
  end

  # @route PATCH /todo_lists/:todo_list_id/todo_items/:id (todo_list_todo_item)
  # @route PUT /todo_lists/:todo_list_id/todo_items/:id (todo_list_todo_item)
  def update
    respond_to do |format|
      if @todo_item.update(todo_item_params)
        format.html { redirect_to todo_list_path(@todo_list), notice: 'Todo item was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  # @route DELETE /todo_lists/:todo_list_id/todo_items/:id (todo_list_todo_item)
  def destroy
    respond_to do |format|
      if @todo_item.destroy
        format.html { redirect_to todo_list_url(@todo_list), notice: 'Todo list was successfully destroyed.' }
        format.turbo_stream
      else
        format.html { redirect_to todo_list_url(@todo_list), alert: 'Todo list could not be destroyed.' }
        format.turbo_stream
      end
    end
  end

  private

  def find_todo_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def find_todo_item
    @todo_item = @todo_list.todo_items.find(params[:id])
  end

  def todo_item_params
    params.require(:todo_item).permit(:title, :description, :completed)
  end
end
