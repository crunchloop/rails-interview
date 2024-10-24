class TodoListsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :destroy, :complete, :generate_lists]

  def index
    @todo_lists = TodoList.all
    @todo_list_count = TodoList.count


    respond_to do |format|
      format.html # Renderiza la vista index.html.erb por defecto
      format.json # Renderiza la vista index.json.jbuilder cuando se solicita JSON
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
      format.html # Renderiza la vista index.html.erb por defecto
      format.json # Renderiza la vista usando show.json.jbuilder    <-----------
    end
  end

  def complete
    @todo_list = TodoList.find(params[:id])

    # Disparar el trabajo en segundo plano
    CompleteTodoListJob.perform_later(@todo_list.id)

    respond_to do |format|
      format.html { redirect_to todo_lists_path, notice: 'Task is being complete in background.' }
      format.turbo_stream # Para manejar la respuesta turbo
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

  def generate_lists
    3.times do
      # Generar una TodoList con datos aleatorios
      todo_list = TodoList.create(
        name: Faker::Lorem.sentence(word_count: 3),
      )

      # Generar un número aleatorio de TodoItems entre 1 y 1000
      rand(1..10000).times do
        todo_list.todo_items.create(
          name: Faker::Lorem.sentence(word_count: 2),
          description: Faker::Lorem.sentence(word_count: 10),
          is_completed: [false].sample
        )
      end
    end

    render json: { message: "30.000 TodoLists with TodoItems created ok." }, status: :ok

  end

  private

  def todo_list_params
    params.require(:todo_list).permit(
      :name, 
      todo_items_attributes: [:name, :description, :is_complete]
    )
  end
end
