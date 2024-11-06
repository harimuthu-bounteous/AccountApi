class UsersController < ApplicationController
  skip_before_action :authenticate_user, only: [ :register, :login ]

  def register
    result = UserService.register_user(user_params)
    if result[:errors]
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    else
      render json: { user: result[:user], token: result[:token] }, status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Error in register : #{e.record.errors.full_messages}")
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def register_admin
    result = UserService.register_admin(user_params)
    if result[:errors]
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    else
      render json: { user: result[:user], token: result[:token] }, status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Error in register_admin : #{e.record.errors.full_messages}")
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def login
    result = UserService.login(params[:email], params[:password])
    if result[:errors]
      render json: { errors: result[:errors] }, status: :unauthorized
    else
      render json: { user: result[:user], token: result[:token] }, status: :ok
    end
  rescue StandardError => e
    Rails.logger.error("Error in login : #{e.message}")
    render json: { errors: [ e.message ] }, status: :not_found
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :username)
  end
end
