class TransactionsController < ApplicationController
  before_action :authenticate_user!

  def create
    account = current_user.accounts.find(params[:account_id])
    amount = params[:amount].to_d

    case params[:transaction_type]
    when "deposit"
      account.update!(balance: account.balance + amount)
      transaction = account.transactions.create!(amount: amount, transaction_type: "deposit")
    when "withdrawal"
      if account.balance >= amount
        account.update!(balance: account.balance - amount)
        transaction = account.transactions.create!(amount: amount, transaction_type: "withdrawal")
      else
        render json: { error: "Insufficient funds" }, status: :unprocessable_entity and return
      end
    end
    render json: transaction, status: :created
  end
end
