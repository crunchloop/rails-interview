class ApplicationController < ActionController::Base
  rescue_from ActionController::UnknownFormat, with: :raise_not_found
 
  skip_before_action :verify_authenticity_token

  def raise_not_found
    raise ActionController::RoutingError.new('Not supported format')
  end
end
