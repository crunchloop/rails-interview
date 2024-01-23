module Api
  class TodoListsController < ApiController
    before_action :find_todo_list, only: %i[update destroy]
    # @route GET /api/todolists (api_todo_lists)
    def index
      @todo_lists = TodoList.all
    end

    # @route POST /api/todolists (api_todo_lists)
    def create
      @todo_list = TodoList.create!(todo_list_params)

      render partial: 'api/todo_lists/todo_list_info', locals: { todo_list: @todo_list }
    end

    # @route PATCH /api/todolists/:id (api_todo_list)
    # @route PUT /api/todolists/:id (api_todo_list)
    def update
      @todo_list.update!(todo_list_params)

      render partial: 'api/todo_lists/todo_list_info', locals: { todo_list: @todo_list }
    end

    # @route DELETE /api/todolists/:id (api_todo_list)
    def destroy
      @todo_list.destroy!
    end

    private

    def find_todo_list
      @todo_list = TodoList.find(params[:id])
    end

    def todo_list_params
      params.require(:todo_list).permit(:name, :description)
    end
  end

end
