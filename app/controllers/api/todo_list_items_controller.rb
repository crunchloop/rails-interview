module Api
  class TodoListItemsController < BaseController

    before_action :set_todo_list
    before_action :set_todo_list_item, only: %i[update destroy]

    def create
      item = @todo_list.todo_list_items.create!(todo_list_item_params)
      render json: item, status: :created
    end

    def update
      @todo_list_item.update!(todo_list_item_params)
      render json: @todo_list_item, status: :ok
    end

    def destroy
      @todo_list_item.destroy!
      head :no_content
    end

    private

    def set_todo_list
      @todo_list = current_user.todo_lists.find(params[:todo_list_id])
    end

    def set_todo_list_item
      @todo_list_item = @todo_list.todo_list_items.find(params[:id])
    end

    def todo_list_item_params
      params.require(:todo_list_item).permit(:description, :status)
    end
  end
end
