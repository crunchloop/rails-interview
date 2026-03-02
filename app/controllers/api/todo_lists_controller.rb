module Api
  class TodoListsController < ApiController
    before_action :set_todo_list, only: %i[show update destroy]

    # GET /api/todolists
    def index
      render json: TodoList.all
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
