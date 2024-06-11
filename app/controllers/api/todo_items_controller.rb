module Api
  class TodoItemsController < ApplicationController
    before_action :get_todo_list
    before_action :get_todo_item, only: %i[destroy show update]

    # POST /api/todolists/:todo_list_id/todoitems
    def create
      @todo_item = TodoItem.new(create_params.merge(todo_list_id: @todo_list.id))
      if @todo_item.save
        render :show, status: :created
      else
        render json: @todo_item.errors, status: :bad_request
      end
    end

    # DELETE /api/todolists/:todo_list_id/todoitems/:id
    def destroy
      @todo_item.destroy
    end

    # GET /api/todolists/:todo_list_id/todoitems
    def index
      @todo_items = @todo_list.todo_items

      respond_to :json
    end

    # GET /api/todolists/:todo_list_id/todoitems/:id
    def show
      render :show, status: :ok
    end

    # PUT /api/todolists/:todo_list_id/todoitems/:id
    def update
      @todo_item.update(update_params)
      if @todo_item.save
        render :show, status: :ok
      else
        render json: @todo_item.errors, status: :bad_request
      end
    end

    private

    def create_params
      params.require(:todo_item).permit(:name, :done)
    end

    def get_todo_item
      @todo_item = @todo_list.todo_items.find(params[:id])
    end

    def get_todo_list
      @todo_list = TodoList.find(params[:todo_list_id])
    end

    def update_params
      params.require(:todo_item).permit(:name, :done)
    end
  end
end
