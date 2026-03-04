module Api
  class TodoListsController < ApiController
    before_action :set_todo_list, only: %i[show update destroy bulk_update_state]

    # GET /api/todolists
    # Supports filtering via Ransack: ?q[name_cont]=shopping
    # Supports pagination: ?page=1&per_page=10
    def index
      raise ActionController::RoutingError, 'Not supported format' unless request.format.json?

      per_page = (params[:per_page] || 10).to_i
      @q = TodoList.ransack(params[:q])
      todo_lists = @q.result(distinct: true).page(params[:page]).per(per_page)

      render json: {
        todo_lists: todo_lists.as_json(only: %i[id name]),
        meta: {
          current_page: todo_lists.current_page,
          total_pages: todo_lists.total_pages,
          total_count: todo_lists.total_count,
          per_page: todo_lists.limit_value
        }
      }
    end

    # GET /api/todolists/:id
    def show
      render json: @todo_list
    end

    # POST /api/todolists
    def create
      @todo_list = TodoList.new(todo_list_params)

      if @todo_list.save
        render json: @todo_list, status: :created
      else
        render json: { errors: @todo_list.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/todolists/:id
    def update
      if @todo_list.update(todo_list_params)
        render json: @todo_list
      else
        render json: { errors: @todo_list.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH /api/todolists/:id/bulk_update_state
    def bulk_update_state
      new_state = params[:state]
      unless TodoItem::STATES.include?(new_state)
        return render json: { error: "Invalid state. Must be one of: #{TodoItem::STATES.join(', ')}" },
                      status: :unprocessable_entity
      end

      @todo_list.todo_items.each do |item|
        UpdateTodoItemStateJob.perform_later(item.id, new_state)
      end
      render json: { message: "Bulk state update enqueued" }, status: :accepted
    end

    # DELETE /api/todolists/:id
    def destroy
      @todo_list.destroy

      head :no_content
    end

    private

    def set_todo_list
      @todo_list = TodoList.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "TodoList not found" }, status: :not_found
    end

    def todo_list_params
      params.require(:todo_list).permit(:name)
    end
  end
end
