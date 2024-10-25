class ApplicationController < ActionController::Base
  rescue_from ActionController::UnknownFormat, with: :raise_not_found
  rescue_from ActiveRecord::RecordNotFound, with: :not_found


  def raise_not_found
    raise ActionController::RoutingError.new('Not supported format')
  end

  private
  
  def not_found
    render plain: "404 Not Found", status: 404
  end
end
