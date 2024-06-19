# frozen_string_literal: true

module Api
  class TodoItemsController < BaseController
    before_action :find_todo_list
    before_action :find_todo_item, only: %i[show update destroy]

    # GET /api/todolists/:todo_list_id/todoitems
    def index
      @todo_items = @todo_list.todo_items

      render status: :ok
    end

    # GET /api/todolists/:todo_list_id/todoitems/:id
    def show
      render status: :ok
    end

    # POST /api/todolists/:todo_list_id/todoitems
    def create
      @todo_item = @todo_list.todo_items.new(todo_item_params)

      return render status: :created if @todo_item.save

      render_error
    end

    # PUT /api/todolists/:todo_list_id/todoitems/:id
    def update
      return render status: :ok if @todo_item.update(todo_item_params)

      render_error
    end

    # DELETE /api/todolists/:todo_list_id/todoitems/:id
    def destroy
      if @todo_item.destroy
        render json: { message: "ToDo Item №#{params[:id]} was successfully deleted" },
               status: :no_content
      else
        render_error
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
      params.require(:todo_item).permit(:name, :description, :completed, :todo_list_id)
    end

    def render_error
      render json: @todo_item.errors, status: :unprocessable_entity
    end
  end
end

# http://127.0.0.1:3000/api/todolists/:todo_list_id/todoitems(.:format)
# 1. Complete CRUD TodoItems/TodoLists API
# 2. RSpec
