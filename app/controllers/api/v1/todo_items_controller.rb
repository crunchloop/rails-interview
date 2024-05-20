# frozen_string_literal: true

module Api
  module V1
    class TodoItemsController < BaseApiController
      before_action :find_todo_item, only: %i[update destroy]

      def index
        @todo_items = TodoItem.where(todo_list_id: todo_items_params[:todo_list_id])
      end

      def create
        TodoList.find(todo_items_params[:todo_list_id])

        @todo_item = TodoItem.new(todo_items_params.merge(completed: false))

        if @todo_item.save
          render status: :created
        else
          render json: @todo_item.errors, status: :unprocessable_entity
        end
      end

      def update
        if @todo_item.update(todo_items_params)
          render status: :ok
        else
          render json: @todo_item.errors, status: :unprocessable_entity
        end
      end

      def destroy
        if @todo_item.destroy
          head :no_content
        else
          render json: @todo_item.errors, status: :unprocessable_entity
        end
      end

      private

      def todo_items_params
        params.permit(:id, :todo_list_id, :name, :description)
      end

      def find_todo_item
        @todo_item = TodoItem.find(todo_items_params[:id])
      end
    end
  end
end
