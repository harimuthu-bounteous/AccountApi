# app/controllers/transactions_controller.rb
class ApplicationController < ActionController::API
  before_action :authenticate_user

  # Auth methods
  def authenticate_user
    header = request.headers["Authorization"]
    token = header.split(" ").last
    decoded = JwtService.decode(token)

    @current_user = User.find_by(id: decoded["user_id"])

  rescue StandardError => e
    Rails.logger.error("Error during authentication: #{e.message}")
    render json: { errors: [ "Unauthorized", e.message ] }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  def authorize_admin!
    # Rails.logger.info("AdminCheck - Current user: #{@current_user}")
    render json: { errors: [ "Forbidden" ] }, status: :forbidden unless @current_user&.admin?
  end

  def authorize_user!
    render json: { errors: [ "Forbidden" ] }, status: :forbidden unless @current_user&.user?
  end

  def authorize_user_or_admin!
    render json: { errors: [ "Forbidden" ] }, status: :forbidden unless @current_user&.user? || @current_user&.admin?
  end
end
