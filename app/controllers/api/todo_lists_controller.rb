module Api
  class TodoListsController < ApplicationController
    # GET /todolists
    def index
      if request.format.html?
        raise ActionController::RoutingError.new('Not supported format')
      else
        @todo_lists = TodoList.all
        render json: @todo_lists
      end
    end

    # GET /todolists/new
    def new
      @todo_list = TodoList.new

      render json: @todo_lists
    end
  end
end
