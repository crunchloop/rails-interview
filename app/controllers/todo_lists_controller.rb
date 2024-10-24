class TodoListsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :destroy]

  def index
    @todo_lists = TodoList.all

    respond_to do |format|
      format.json  # Esto busca la vista index.json.jbuilder
    end
  end

  def new
    @todo_list = TodoList.new

    respond_to :html
  end

  def create
    todo_list = TodoList.new(todo_list_params)

    if todo_list.save
      render json: { message: 'TodoList with TodoItems were created successfully!', todo_list: todo_list }, status: :created
    else
      render json: { errors: todo_list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    @todo_list = TodoList.find(params[:id])
    
    respond_to do |format|
      format.json  
      # Renderiza la vista usando show.json.jbuilder
    end
  end

  def destroy
    @todo_list = TodoList.find(params[:id])
    
    if @todo_list.destroy
      render json: { message: "TodoList deleted successfully" }, status: :ok
    else
      render json: { error: "Failed to delete TodoList" }, status: :unprocessable_entity
    end
  end

  private

  def todo_list_params
    params.require(:todo_list).permit(
      :name, 
      todo_items_attributes: [:name, :description, :is_complete]
    )
  end
end
