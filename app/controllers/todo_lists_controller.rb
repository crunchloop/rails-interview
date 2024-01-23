class TodoListsController < ApplicationController
  before_action :find_todo_list, only: %i[edit update destroy show]

  # @route GET /todolists (todo_lists)
  def index
    @todo_lists = TodoList.all

    respond_to :html
  end

  def show
    respond_to :html
  end

  # @route GET /todolists/new (new_todo_list)
  def new
    @todo_list = TodoList.new

    respond_to :html
  end

  # @route POST /todolists (todo_lists)
  def create
    @todo_list = TodoList.new(todo_list_params)

    respond_to do |format|
      if @todo_list.save
        format.html { redirect_to todo_lists_path, notice: 'Todo list was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  # @route GET /todolists/:id/edit (edit_todo_list)
  def edit
    @todo_list = TodoList.find(params[:id])

    respond_to :html
  end

  # @route PATCH /todolists/:id (todo_list)
  # @route PUT /todolists/:id (todo_list)
  def update
    respond_to do |format|
      if @todo_list.update(todo_list_params)
        format.html { redirect_to todo_lists_path, notice: 'Todo list was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  # @route DELETE /todolists/:id (todo_list)
  def destroy
    respond_to do |format|
      if @todo_list.destroy
        format.turbo_stream
        format.html { redirect_to todo_lists_url, notice: 'Todo list was successfully destroyed.' }
      else
        format.html { redirect_to todo_lists_url, alert: 'Todo list could not be destroyed.' }
        format.turbo_stream
      end
    end
  end

  private

  def todo_list_params
    params.require(:todo_list).permit(:name, :completed)
  end

  def find_todo_list
    @todo_list = TodoList.find(params[:id])
  end
end
