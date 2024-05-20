# frozen_string_literal: true

module Api
  module V1
    class TodoListsController < BaseApiController
      def index
        @todo_lists = TodoList.all
      end

      def complete_all
        TodoList.find(todo_list_params[:id])
        CompleteAllItemsWorker.perform_async(todo_list_params[:id])

        head :no_content
      end

      private

      def todo_list_params
        params.permit(:id)
      end
    end
  end
end
