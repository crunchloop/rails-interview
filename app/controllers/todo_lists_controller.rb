class TodoListsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :destroy, :complete, :generate_lists]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from StandardError, with: :standard_error

  def index
    @todo_lists = TodoList.all
    @todo_list_count = TodoList.count

    respond_to do |format|
      format.html # Renderiza la vista index.html.erb por defecto
      format.json # Renderiza la vista index.json.jbuilder cuando se solicita JSON
    end
  rescue StandardError => e
    handle_standard_error(e)
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
      format.html # Renderiza la vista show.html.erb por defecto
      format.json # Renderiza la vista usando show.json.jbuilder
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def complete
    @todo_list = TodoList.find(params[:id])
    selected_items = params[:selected_items]

    if selected_items.present?
      CompleteTodoItemsJob.perform_later(@todo_list.id, selected_items)
      render json: { message: 'Todo list marked as complete' }, status: :ok # <-- NEW LINE
    else
      render json: { error: 'No items selected' }, status: :unprocessable_entity
      return
    end

    respond_to do |format|
      format.turbo_stream
      format.json { render json: { message: 'Todo list marked as complete' }, status: :ok }
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def destroy
    @todo_list = TodoList.find(params[:id])

    if @todo_list.destroy
      render json: { message: "TodoList deleted successfully" }, status: :ok
    else
      render json: { error: "Failed to delete TodoList" }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  rescue StandardError => e
    handle_standard_error(e)
  end

  def generate_lists
    ActiveRecord::Base.transaction do
      1.times do
        todo_list = TodoList.create!(name: Faker::Lorem.sentence(word_count: 3))

        rand(1..50).times do
          todo_list.todo_items.create!(
            name: Faker::Lorem.sentence(word_count: 2),
            description: Faker::Lorem.sentence(word_count: 10),
            is_completed: [false].sample
          )
        end
      end
    end

    render json: { message: "Random number of TodoLists with TodoItems created successfully." }, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def todo_list_params
    params.require(:todo_list).permit(
      :name, 
      todo_items_attributes: [:name, :description, :is_complete]
    )
  end

  # Error handling and messages

  def record_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def record_invalid(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end

  def parameter_missing(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end

  def standard_error(exception)
    render json: { error: "An unexpected error occurred: #{exception.message}" }, status: :internal_server_error
  end

  def handle_standard_error(exception)
    Rails.logger.error("Error: #{exception.message}")
    render json: { error: "An unexpected error occurred" }, status: :internal_server_error
  end
end
