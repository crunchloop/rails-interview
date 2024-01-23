module Api
  class TodoItemsController < ApiController
    before_action :find_todo_list
    before_action :find_todo_item, only: %i[update destroy]

    # @route GET /api/todolists/:todo_list_id/todoitems (api_todo_list_todo_items)
    def index
      @todo_items = @todo_list.todo_items
    end

    # @route POST /api/todolists/:todo_list_id/todoitems (api_todo_list_todo_items)
    def create
      @todo_item = @todo_list.todo_items.create!(todo_item_params)

      render partial: 'api/todo_items/todo_item_info', locals: { todo_item: @todo_item }
    end

    # @route PATCH /api/todolists/:todo_list_id/todoitems/:id (api_todo_list_todo_item)
    # @route PUT /api/todolists/:todo_list_id/todoitems/:id (api_todo_list_todo_item)
    def update
      @todo_item.update!(todo_item_params)

      render partial: 'api/todo_items/todo_item_info', locals: { todo_item: @todo_item }
    end

    # @route DELETE /api/todolists/:todo_list_id/todoitems/:id (api_todo_list_todo_item)
    def destroy
      @todo_item.destroy!
    end

    private

    def find_todo_list
      @todo_list = TodoList.find(params[:todo_list_id])
    end

    def find_todo_item
      @todo_item = @todo_list.todo_items.find(params[:id])
    end

    def todo_item_params
      params.require(:todo_item).permit(:title, :description, :completed)
    end
  end
end
