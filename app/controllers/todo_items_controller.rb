class TodoItemsController < ApplicationController
  before_action :set_todo_list, only: %i[ create edit update destroy complete undo_complete ]
  before_action :set_todo_item, only: %i[ edit update destroy complete undo_complete ]

  def create
    @todo_list.todo_items.create!(todo_item_params)
    redirect_to @todo_list
  end

  def edit
  end

  def update
    @todo_item.update!(todo_item_params)
    redirect_to @todo_list
  end

  def destroy
    @todo_item.destroy
    render turbo_stream: turbo_stream.remove(helpers.dom_id(@todo_item, :edit))
  end

  def complete
    @todo_item.complete!
    redirect_to @todo_list
  end

  def undo_complete
    @todo_item.undo_complete!
    redirect_to @todo_list
  end

  private

  def todo_item_params
    params.require(:todo_item).permit(%i[ name ])
  end

  def set_todo_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def set_todo_item
    @todo_item = @todo_list.todo_items.find(params[:id])
  end
end
