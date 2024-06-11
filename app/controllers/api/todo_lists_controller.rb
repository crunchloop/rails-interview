module Api
  class TodoListsController < ApplicationController
    before_action :get_todo_list, only: %i[destroy show update]

    # POST /api/todolists
    def create
      @todo_list = TodoList.new(create_params)
      if @todo_list.save
        render :show, status: :created
      else
        render json: @todo_list.errors, status: :bad_request
      end
    end

    # DELETE /api/todolists/:id
    def destroy
      @todo_list.destroy
    end

    # GET /api/todolists
    def index
      @todo_lists = TodoList.all

      respond_to :json
    end

    # GET /api/todolists/:id
    def show
      render :show, status: :ok
    end

    # PUT /api/todolists/:id
    def update
      @todo_list.update(update_params)
      if @todo_list.save
        render :show, status: :ok
      else
        render json: @todo_list.errors, status: :bad_request
      end
    end

    private

    def create_params
      params.require(:todo_list).permit(:name)
    end

    def get_todo_list
      @todo_list = TodoList.find(params[:id])
    end

    def update_params
      params.require(:todo_list).permit(:name)
    end
  end
end
