module Api
  class TodoListsController < ApiController
    include TodoListActions

    before_action :set_todo_list, only: %i[ update destroy ]

    # GET /api/todolists
    def index
      @todo_lists = TodoList.all

      respond_to :json
    end

    # POST /api/todolists
    def create
      if create_todo_list
        render json: @todo_list, status: :ok
      else
        render json: { errors: @todo_list.errors }, status: :unprocessable_entity
      end
    end

    # PUT /api/todolists/:id
    def update
      if update_todo_list
        render json: @todo_list, status: :ok
      else
        render json: { errors: @todo_list.errors }, status: :unprocessable_entity
      end
    end

    # DELETE /api/todolists/:id
    def destroy
      destroy_todo_list!
      head :no_content
    end
  end
end
