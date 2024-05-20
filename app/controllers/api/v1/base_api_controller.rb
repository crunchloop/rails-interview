# frozen_string_literal: true

module Api
  module V1
    class BaseApiController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      private

      def record_not_found(exception)
        render json: { error: "Record not found for #{exception.model}" }, status: :not_found
      end
    end
  end
end
