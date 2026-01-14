class TodoItemsController < ApplicationController
  before_action :set_todo_list
  before_action :set_todo_item, only: %i[edit update destroy mark_as_complete show]

  def new
    @todo_item = @todo_list.todo_items.build
  end

  def create
    @todo_item = @todo_list.todo_items.build(todo_item_params)

    if @todo_item.save
      redirect_to [@todo_list, @todo_item], notice: t('.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit; end

  def update
    if @todo_item.update(todo_item_params)
      redirect_to [@todo_list, @todo_item], notice: t('.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @todo_item.destroy
    redirect_to @todo_list, notice: t('.destroyed')
  end

  def mark_as_complete
    if @todo_item.update(complete: true)
      redirect_to @todo_list, notice: t('.marked_as_complete')
    else
      redirect_to @todo_list, alert: @todo_item.errors.full_messages.to_sentence
    end
  end

  private

  def todo_item_params
    params.require(:todo_item).permit(:title, :description)
  end

  def set_todo_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def set_todo_item
    @todo_item = @todo_list.todo_items.find(params[:id])
  end
end
