module Api
  class UsersController < ApplicationController

    def create
      # puts params.inspect
      user = User.new(user_params)
      
      if user.save
        token = encode_token({ user_id: user.id })
        render json: { token: token }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end

    def encode_token(payload)
      JWT.encode(payload, Rails.application.secrets.secret_key_base)
    end
  end
end
