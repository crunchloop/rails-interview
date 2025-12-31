class TodoListsController < ApplicationController
  before_action :set_todo_list, only: %i[edit update destroy mark_all_done]
  before_action :set_todo_list_with_items, only: %i[show]

  # GET /todolists
  def index
    @todo_lists = TodoList.all
    @todo_list = TodoList.new
  end

  # GET /todolists/:id
  def show; end

  # GET /todolists/new
  def new
    @todo_list = TodoList.new
  end

  # GET /todolists/:id/edit
  def edit; end

  # POST /todolists
  def create
    @todo_list = TodoList.new(todo_list_params)

    respond_to do |format|
      if @todo_list.save
        format.html { redirect_to todo_lists_path, notice: t('todo_lists.created') }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /todolists/:id
  def update
    respond_to do |format|
      if @todo_list.update(todo_list_params)
        format.html { redirect_to todo_lists_path, notice: t('todo_lists.updated') }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /todolists/:id
  def destroy
    @todo_list.destroy
    respond_to do |format|
      format.html { redirect_to todo_lists_path, notice: t('todo_lists.destroyed') }
      format.turbo_stream
    end
  end

  # POST /todolists/:id/mark_all_done
  def mark_all_done
    UpdateListItemsJob.perform_later(@todo_list.id, done: true)
    respond_to do |format|
      format.html { redirect_to @todo_list, notice: t('todo_lists.updating_all') }
      format.turbo_stream { flash.now[:notice] = t('todo_lists.updating_all') }
    end
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:id])
  end

  def set_todo_list_with_items
    @todo_list = TodoList.includes(:list_items).find(params[:id])
  end

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end
end
