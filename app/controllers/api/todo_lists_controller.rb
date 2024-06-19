# frozen_string_literal: true

module Api
  class TodoListsController < BaseController
    before_action :find_todo_list, only: %i[show update destroy]

    # GET /api/todolists
    def index
      @todo_lists = TodoList.all

      render status: :ok
    end

    # POST /api/todolists
    def create
      @todo_list = TodoList.new(todo_list_params)

      return render status: :created if @todo_list.save

      render_error
    end

    # GET /api/todolists/:id
    def show
      render status: :ok
    end

    # PUT /api/todolists/:id
    def update
      return render status: :ok if @todo_list.update(todo_list_params)

      render_error
    end

    # DELETE /api/todolists/:id
    def destroy
      if @todo_list.destroy
        render json: { message: "ToDo List №#{params[:id]} was successfully deleted" },
               status: :no_content
      else
        render_error
      end
    end

    private

    def find_todo_list
      @todo_list = TodoList.find(params[:id])
    end

    def todo_list_params
      params.require(:todo_list).permit(:name)
    end

    def render_error
      render json: @todo_list.errors, status: :unprocessable_entity
    end
  end
end
