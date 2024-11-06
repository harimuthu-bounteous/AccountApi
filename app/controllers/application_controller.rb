class ApplicationController < ActionController::API
  before_action :authenticate_user

  # Auth methods
  def authenticate_user
    header = request.headers["Authorization"]
    if header
      token = header.split(" ").last
      decoded = JwtService.decode(token)
      @current_user = User.find(decoded[:user_id]) if decoded
    end
  end

  def current_user
    @current_user
  end

  def authorize_admin!
    render json: { errors: [ "Forbidden" ] }, status: :forbidden unless @current_user&.admin?
  end

  def authorize_user!
    render json: { errors: [ "Forbidden" ] }, status: :forbidden unless @current_user&.user?
  end

  def authorize_user_or_admin!
    render json: { errors: [ "Forbidden" ] }, status: :forbidden unless @current_user&.user? || @current_user&.admin?
  end
end
