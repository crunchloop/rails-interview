# frozen_string_literal: true

class TodoListsController < BaseController
  before_action :load_todo_lists, only: %i[index create]
  before_action :load_todo_list, only: %i[show edit update destroy]

  # GET /todolists
  def index
    build_todo_list

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # POST /todolists
  def create
    build_todo_list(todo_list_params)

    save_todo_list('created') or render_new_todo_list
  end

  # GET /todolists/:id
  def show; end

  # GET /todolists/:id/edit
  def edit; end

  # PUT /todolists/:id
  def update
    build_todo_list(todo_list_params)

    save_todo_list('updated') or render_edit_todo_list
  end

  # DELETE /todolists/:id
  def destroy
    @todo_list.destroy
    respond_to_destroy
  end

  private

  def load_todo_list
    @todo_list = TodoList.find(params[:id])
  end

  def load_todo_lists
    @todo_lists = TodoList.all
  end

  def build_todo_list(params = {})
    @todo_list ||= TodoList.new
    @todo_list.attributes = params
  end

  def save_todo_list(action)
    return unless @todo_list.save

    respond_to do |format|
      format.html { redirect_to todo_lists_path, notice: "ToDo List was successfully #{action}." }
      format.turbo_stream { render_success_turbo_stream(action) }
    end
  end

  def render_new_todo_list
    respond_to do |format|
      format.html { render :index }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('new_todo_list', partial: 'form', locals: { todo_list: @todo_list })
      end
    end
  end

  def render_edit_todo_list
    respond_to do |format|
      format.html { render :edit }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(dom_id(@todo_list), partial: 'form',
                                                                      locals: { todo_list: @todo_list })
      end
    end
  end

  def respond_to_destroy
    respond_to do |format|
      format.html { redirect_to todo_lists_url, notice: 'ToDo List was successfully deleted.' }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@todo_list),
          turbo_stream.prepend('flash', partial: 'layouts/flash',
                                        locals: { notice: 'ToDo List was successfully deleted.' })
        ]
      end
    end
  end

  def render_success_turbo_stream(action)
    render turbo_stream: [
      turbo_stream.append('todo_lists', partial: 'todo_list', locals: { todo_list: @todo_list }),
      turbo_stream.replace('new_todo_list', partial: 'form', locals: { todo_list: TodoList.new }),
      turbo_stream.prepend('flash', partial: 'layouts/flash',
                                    locals: { notice: "ToDo List was successfully #{action}." })
    ]
  end

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end
end
