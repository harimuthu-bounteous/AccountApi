class AccountsController < ApplicationController
  before_action :authenticate_user!

  def create
    @account = current_user.accounts.create
    render json: @account, status: :created
  end

  def show
    @account = current_user.accounts.find(params[:id])
    render json: @account
  end
end
