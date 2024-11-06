class ApplicationController < ActionController::API
  before_action :authenticate_user

  # Auth methods
  def authenticate_user
    header = request.headers["Authorization"]
    if header
      token = header.split(" ").last
      decoded = JwtService.decode(token)

      # Log decoded token
      Rails.logger.info("Decoded token: #{decoded.inspect}")

      if decoded && decoded["user_id"]
        # Ensure user_id is treated as a UUID
        @current_user = User.find_by(id: decoded["user_id"])
        if @current_user
          Rails.logger.info("Current user: #{@current_user.inspect}")
        else
          Rails.logger.warn("User not found with ID: #{decoded['user_id']}")
        end
      else
        Rails.logger.warn("No user_id found in decoded token")
      end

    else
      Rails.logger.warn("Authorization header missing")
    end
  rescue StandardError => e
    Rails.logger.error("Error during authentication: #{e.message}")
    render json: { errors: [ "Unauthorized", e.message ] }, status: :unauthorized
  end


  def current_user
    @current_user
  end

  def authorize_admin!
    Rails.logger.info("AdminCheck - Current user: #{@current_user}")
    render json: { errors: [ "Forbidden" ] }, status: :forbidden unless @current_user&.admin?
  end

  def authorize_user!
    render json: { errors: [ "Forbidden" ] }, status: :forbidden unless @current_user&.user?
  end

  def authorize_user_or_admin!
    render json: { errors: [ "Forbidden" ] }, status: :forbidden unless @current_user&.user? || @current_user&.admin?
  end
end
