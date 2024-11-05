class AccountsController < ApplicationController
  before_action :set_account, only: [ :show, :update, :destroy ]
  # before_action :authorize_admin!, only: [ :index ]
  before_action :authorize_user_or_admin!, only: [ :show, :create, :update, :destroy ]

  # GET /accounts
  # Accessible only by admin
  def index
    if current_user.admin?
      @accounts = Account.includes(:user).select(:id,  :balance, :created_at, :user_id)
      render json: @accounts.as_json(include: { user: { only: [ :id, :username, :email ] } })
    else
      render json: { error: "Access denied" }, status: :forbidden
    end
  end

  # GET /accounts/:account_number
  # Accessible by account owner or admin
  def show
    render json: @account
  end

  # POST /accounts
  def create
    # Rails.logger.info("Current user: #{current_user.inspect}")
    unless current_user
      return render json: { errors: [ "Unauthorized in here" ] }, status: :unauthorized
    end
    @account = current_user.accounts.build
    @account.balance ||= 0 # Ensure balance is set to zero if not provided
    if @account.save
      render json: @account, status: :created
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end


  # PUT /accounts/:account_number
  def update
    if @account.update(account_params)
      render json: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # DELETE /accounts/:account_number
  def destroy
    @account.destroy
    head :no_content
  end

  private

  # def set_account
  #   @account = Account.find(params[:id])
  #   authorize_account_access!(@account)
  # end

  def authorize_account_access!(account)
    unless account.user_id == current_user.id || current_user.admin?
      render json: { errors: [ "Forbidden" ] }, status: :forbidden
    end
  end

  def account_params
    params.require(:account).permit(:balance)
  end

  def set_account
    @account = Account.find_by(account_number: params[:account_number])
    unless @account
      render json: { error: "Account not found" }, status: :not_found and return
    end
    authorize_account_access!(@account)
  end
end
