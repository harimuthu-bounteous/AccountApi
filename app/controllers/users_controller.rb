class UsersController < ApplicationController
  skip_before_action :authenticate_user, only: [ :register, :login ]

  def register
    @user = User.new(user_params)
    if @user.save
      token = encode_token({ user_id: @user.id })
      render json: { user: @user, token: token }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def register_admin
    @user = User.new(user_params.merge(role: "admin"))
    if @user.save
      token = encode_token({ user_id: @user.id })
      render json: { user: @user, token: token }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      token = encode_token({ user_id: @user.id })
      render json: { user: { id: @user.id, username: @user.username, email: @user.email, role: @user.role }, token: token }, status: :ok
    else
      render json: { errors: [ "Invalid email or password" ] }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :username)
  end

  def encode_token(payload)
    payload[:exp] = 1.day.from_now.to_i
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end
end
