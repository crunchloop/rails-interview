class TodoListsController < ApplicationController
  before_action :set_todo_list, only: %i[show mark_all_todo_items_as_complete]
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

  def show; end

  def mark_all_todo_items_as_complete
    CompleteTodoListItemsJob.perform_later(@todo_list.id)

    redirect_to @todo_list, notice: t('.marking_items')
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:id])
  end
end
