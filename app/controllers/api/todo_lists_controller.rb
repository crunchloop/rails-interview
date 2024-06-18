# frozen_string_literal: true

module Api
  class TodoListsController < ApplicationController
    # GET /api/todolists
    def index
      @todo_lists = TodoList.all

      respond_to :json
    end
  end
end
