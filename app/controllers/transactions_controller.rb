class TransactionsController < ApplicationController
  before_action :set_transaction, only: [ :show ]
  before_action :set_account, only: [ :create ]
  before_action :authorize_user_or_admin!, only: [ :index, :show, :create ]

  # GET /transactions
  def index
    @transactions = current_user.admin? ? Transaction.all : current_user_transactions
    render json: @transactions
  end

  # GET /transactions/:id
  def show
    render json: @transaction
  end

  # POST /transactions
  def create
    @transaction = @account.transactions.build(transaction_params)
    if @transaction.save
      update_account_balance!(@transaction)
      render json: @transaction, status: :created
    else
      render json: @transaction.errors, status: :unprocessable_entity
    end
  end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
    authorize_transaction_access!(@transaction)
  end

  def set_account
    @account = Account.find(params[:account_id])
    authorize_account_access!(@account)
  end

  def authorize_account_access!(account)
    unless account.user_id == current_user.id || current_user.admin?
      render json: { errors: [ "Forbidden" ] }, status: :forbidden
    end
  end

  def authorize_transaction_access!(transaction)
    unless transaction.account.user_id == current_user.id || current_user.admin?
      render json: { errors: [ "Forbidden" ] }, status: :forbidden
    end
  end

  def transaction_params
    params.require(:transaction).permit(:amount, :transaction_type)
  end

  def update_account_balance!(transaction)
    case transaction.transaction_type
    when "deposit"
      transaction.account.increment!(:balance, transaction.amount)
    when "withdrawal"
      if transaction.account.balance >= transaction.amount
        transaction.account.decrement!(:balance, transaction.amount)
      else
        render json: { errors: [ "Insufficient funds" ] }, status: :unprocessable_entity
      end
    end
  end

  def current_user_transactions
    Transaction.joins(:account).where(accounts: { user_id: current_user.id })
  end
end
