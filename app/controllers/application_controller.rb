class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  before_action :authenticate_admin_user!, unless: -> { request.format.json? || devise_controller? }
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActionController::UnknownFormat, with: :raise_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :invalid
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def raise_not_found
    raise ActionController::RoutingError.new('Not supported format')
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name username])
  end
end
