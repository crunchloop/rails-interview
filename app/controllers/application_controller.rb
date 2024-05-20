# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from ActionController::UnknownFormat, with: :raise_not_found

  def raise_not_found
    raise ActionController::RoutingError, 'Not supported format'
  end
end
