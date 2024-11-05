class ApplicationController < ActionController::API
  before_action :authenticate_user

  def authenticate_user
    header = request.headers["Authorization"]
    token = header.split(" ").last if header
    decoded = decode_token(token)
    @current_user = User.find(decoded[:user_id]) if decoded
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { errors: [ "Unauthorized" ] }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  private

  def decode_token(token)
    decoded = JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
    HashWithIndifferentAccess.new decoded
  rescue
    nil
  end
end
