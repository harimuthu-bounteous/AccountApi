class AccountsController < ApplicationController
  before_action :set_account, only: [ :show, :update, :destroy ]
  before_action :authorize_admin!, only: [ :index ]
  before_action :authorize_user!, only: [ :show, :create, :update, :destroy ]

  # GET /accounts
  def index
    @accounts = Account.includes(:user)
    render json: @accounts, each_serializer: AccountSerializer
  rescue => e
    render json: { errors: [ "Error in 'accounts#index' : ", e.message ] }, status: :unprocessable_entity
  end

  # GET /accounts/:account_number
  def show
    render json: @account, each_serializer: AccountSerializer
  rescue => e
    render json: { errors: [ "Error in 'accounts#show' : ", e.message ] }, status: :unprocessable_entity
  end

  # POST /accounts
  def create
    begin
      account_service = AccountService.new(current_user, { balance: 0 })
      @account = account_service.create_account
      render json: @account, each_serializer: AccountSerializer, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: [ "Account creation failed", e.message ] }, status: :unprocessable_entity
    end
  end

  # PUT /accounts/:account_number
  def update
    begin
      account_service = AccountService.new(current_user, account_params)
      @account = account_service.update_account(@account)
      render json: AccountSerializer.new(@account).serializable_hash
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: [ "Account update failed", e.message ] }, status: :unprocessable_entity
    end
  end

  # DELETE /accounts/:account_number
  def destroy
    begin
      account_service = AccountService.new(current_user, {})
      account_service.destroy_account(@account)
      head :no_content
    rescue => e
      render json: { errors: [ "Error deleting account", e.message ] }, status: :unprocessable_entity
    end
  end

  private

  def set_account
    @account = Account.find_by(account_number: params[:account_number])
    unless @account
      render json: { error: "Account not found" }, status: :not_found and return
    end
    authorize_account_access!(@account)
  end

  def authorize_account_access!(account)
    unless account.user_id == current_user.id || current_user.admin?
      render json: { errors: [ "Forbidden" ] }, status: :forbidden
    end
  end

  def account_params
    params.require(:account).permit(:balance)
  end
end
