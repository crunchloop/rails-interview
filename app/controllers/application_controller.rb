# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from ActionController::UnknownFormat, with: :raise_not_found
  rescue_from ActiveRecord::RecordNotFound, with: :raise_not_found_item

  def raise_not_found
    raise ActionController::RoutingError, 'Not supported format'
  end

  def raise_not_found_item
    render json: { error: 'Could not find item' }, status: :not_found
  end
end
