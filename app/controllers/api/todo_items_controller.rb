module Api
  class TodoItemsController < ApiController
    before_action :set_todo_list
    before_action :set_todo_item, only: %i[show update destroy]

    # GET /api/todolists/:todo_list_id/items
    # Supports filtering via Ransack: ?q[title_cont]=buy&q[state_eq]=Done
    # Supports pagination: ?page=1&per_page=10
    def index
      per_page = (params[:per_page] || 10).to_i
      @q = @todo_list.todo_items.ransack(params[:q])
      todo_items = @q.result(distinct: true).page(params[:page]).per(per_page)

      render json: {
        todo_items: todo_items,
        meta: {
          current_page: todo_items.current_page,
          total_pages: todo_items.total_pages,
          total_count: todo_items.total_count,
          per_page: todo_items.limit_value
        }
      }
    end

    # GET /api/todolists/:todo_list_id/items/:id
    def show
      render json: @todo_item
    end

    # POST /api/todolists/:todo_list_id/items
    def create
      @todo_item = @todo_list.todo_items.new(todo_item_params)

      if @todo_item.save
        render json: @todo_item, status: :created
      else
        render json: { errors: @todo_item.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/todolists/:todo_list_id/items/:id
    def update
      if @todo_item.update(todo_item_params)
        render json: @todo_item
      else
        render json: { errors: @todo_item.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/todolists/:todo_list_id/items/:id
    def destroy
      @todo_item.destroy

      head :no_content
    end

    private

    def set_todo_list
      @todo_list = TodoList.find(params[:todo_list_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "TodoList not found" }, status: :not_found
    end

    def set_todo_item
      @todo_item = @todo_list.todo_items.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "TodoItem not found" }, status: :not_found
    end

    def todo_item_params
      params.require(:todo_item).permit(:title, :description, :start_date, :end_date, :state)
    end
  end
end
