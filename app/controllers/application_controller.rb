class ApplicationController < ActionController::API
  before_action :authenticate_user

  def authenticate_user
    header = request.headers["Authorization"]
    if header
      token = header.split(" ").last
      decoded = decode_token(token)
      @current_user = User.find(decoded[:user_id]) if decoded
      # Rails.logger.info("Current user set to #{@current_user.inspect}")
    else
      # Rails.logger.error("Authorization header is missing")
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("User not found: #{e.message}")
    render json: { errors: [ "Unauthorized" ] }, status: :unauthorized
  rescue JWT::DecodeError => e
    Rails.logger.error("JWT decode error: #{e.message}")
    render json: { errors: [ "Unauthorized" ] }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  def authorize_admin!
    render json: { errors: [ "Forbidden" ] }, status: :forbidden unless @current_user&.admin?
  end

  def authorize_user_or_admin!
    render json: { errors: [ "Forbidden" ] }, status: :forbidden unless @current_user&.user? || @current_user&.admin?
  end

  private

  def decode_token(token)
    decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue
    nil
  end
end
