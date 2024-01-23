class ApiController < ApplicationController
  rescue_from ActiveRecord::RecordInvalid, with: :invalid
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def invalid(invalid)
    render json: { errors: invalid.record.errors.full_messages }, status: :unprocessable_entity
  end

  def record_not_found(record)
    render json: { errors: "#{record.model} not found" }, status: :not_found
  end
end
