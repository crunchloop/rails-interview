module Api
  class TodoItemsController < ApiController
    include TodoItemActions

    before_action :set_todo_list, only: %i[ create index update ]
    before_action :set_todo_item, only: %i[ update destroy ]

    # GET /api/todolists/:id/todos
    def index
      @todo_items = @todo_list.todo_items

      respond_to :json
    end

    # POST /api/todolists/:id/todos
    def create
      if create_todo_item
        render json: @todo_item, status: :ok
      else
        render json: { errors: @todo_item.errors }, status: :unprocessable_entity
      end
    end

    # PUT /api/todolists/:id/todos/:todo_item_id
    def update
      if update_todo_item
        render json: @todo_item, status: :ok
      else
        render json: { errors: @todo_item.errors }, status: :unprocessable_entity
      end
    end

    # DELETE /api/todolists/:id/todos/:todo_item_id
    def destroy
      destroy_todo_item!
      head :no_content
    end
  end
end