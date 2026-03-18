class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  rescue_from ActionController::UnknownFormat, with: :raise_not_found

  def raise_not_found
    raise ActionController::RoutingError.new('Not supported format')
  end
end
