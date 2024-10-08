class ApplicationController < ActionController::API
  rescue_from ActionController::UnknownFormat, with: :raise_not_found

  def raise_not_found
    raise ActionController::RoutingError.new('Not supported format')
  end
end
