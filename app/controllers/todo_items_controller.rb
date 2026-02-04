class TodoItemsController < ApplicationController
  before_action :set_todo_list, only: %i[ create edit update destroy complete undo_complete ]
  before_action :set_todo_item, only: %i[ edit update destroy complete undo_complete ]

  def create
    @todo_list.todo_items.create!(todo_item_params)
    redirect_to @todo_list
  end

  def edit
    render turbo_stream: turbo_stream.replace(helpers.dom_id(@todo_item, :edit), partial: "todo_items/form", locals: { todo_list: @todo_list, todo_item: @todo_item })
  end

  def update
    @todo_item.update!(todo_item_params)
    redirect_to @todo_list
  end

  def destroy
    @todo_item.destroy
    redirect_to @todo_list, status: :see_other
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
