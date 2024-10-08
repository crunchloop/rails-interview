class ApplicationController < ActionController::API
  rescue_from ActionController::UnknownFormat, with: :raise_not_found
  before_action :authorize_request

  def authorize_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = decode_token(token)
    @current_user = User.find(decoded[:user_id]) if decoded
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { errors: 'Unauthorized access' }, status: :unauthorized
  end

  private

  def decode_token(token)
    JWT.decode(token, Rails.application.secrets.secret_key_base, true, algorithm: 'HS256')[0]
  rescue JWT::DecodeError
    nil
  end

  def raise_not_found
    raise ActionController::RoutingError.new('Not supported format')
  end
end
