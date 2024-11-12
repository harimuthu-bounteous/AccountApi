# app/controllers/api/v1/transactions_controller.rb
module Api
  module V1
    class TransactionsController < ApplicationController
      before_action :set_account, only: [ :create, :show_transactions ]
      before_action :set_transaction, only: [ :show, :update, :destroy ]

      def index
        @transactions = Transaction.all
        render json: @transactions, status: :ok
      rescue => e
        render json: { errors: [ "Error in 'transactions#index' : ", e.message ] }, status: :unprocessable_entity
      end

      def show
        render json: @transaction, status: :ok
      rescue => e
        render json: { errors: [ "Error in 'transactions#show' : ", e.message ] }, status: :unprocessable_entity
      end

      def create
        result = TransactionService.create_transaction(@account, transaction_params)

        if result[:success]
          render json: result[:transaction], status: :created
        else
          render json: { errors: result[:errors] }, status: :unprocessable_entity
        end
      rescue => e
        render json: { errors: [ "Error in 'transactions#create' : ", e.message ] }, status: :unprocessable_entity
      end

      def show_transactions
        result = TransactionService.get_transactions_by_account_number(params[:account_number])

        if result[:success]
          render json: result[:transactions], status: :ok
        else
          render json: { errors: result[:errors] }, status: :not_found
        end
      rescue => e
        render json: { errors: [ "Error in 'transactions#show_transactions' : ", e.message ] }, status: :unprocessable_entity
      end

      def update
        result = TransactionsService.update_transaction(@transaction.account, @transaction, transaction_params)

        if result[:success]
          render json: result[:transaction], status: :ok
        else
          render json: { errors: result[:errors] }, status: :unprocessable_entity
        end
      rescue => e
        render json: { errors: [ "Error in 'transactions#update' : ", e.message ] }, status: :unprocessable_entity
      end

      def destroy
        result = TransactionsService.destroy_transaction(@transaction.account, @transaction)

        if result[:success]
          head :no_content
        else
          render json: { errors: result[:errors] }, status: :unprocessable_entity
        end
      rescue => e
        render json: { errors: [ "Error in 'transactions#destroy' : ", e.message ] }, status: :unprocessable_entity
      end

      private

      def set_account
        @account = Account.find_by(account_number: params[:account_number])
        render json: { errors: [ "Account not found" ] }, status: :not_found unless @account
      end

      def set_transaction
        @transaction = Transaction.find(params[:id])
        render json: { errors: [ "Transaction not found" ] }, status: :not_found unless @transaction
      end

      def transaction_params
        params.require(:transaction).permit(:amount, :transaction_type)
      end
    end
  end
end
