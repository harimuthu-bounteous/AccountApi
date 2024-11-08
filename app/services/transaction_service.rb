# app/services/transactions_service.rb
class TransactionService
  def self.get_transactions_by_account_number(account_number)
    account = Account.find_by(account_number: account_number)
    return { success: false, errors: [ "Account not found" ] } unless account

    { success: true, transactions: account.transactions }
  end

  def self.create_transaction(account, transaction_params)
    # Ensure sufficient balance for withdrawals
    if transaction_params[:transaction_type] == "withdrawal" && account.balance < transaction_params[:amount].to_f
      return { success: false, errors: [ "Insufficient balance" ] }
    end

    transaction = account.transactions.new(transaction_params)

    if transaction.save
      adjust_balance(account, transaction)
      { success: true, transaction: transaction }
    else
      { success: false, errors: transaction.errors.full_messages }
    end
  end

  def self.update_transaction(account, transaction, transaction_params)
    # Calculate balance adjustment based on the old and new transaction amounts
    old_amount = transaction.amount
    new_amount = transaction_params[:amount].to_f

    if transaction_params[:transaction_type] == "withdrawal" && (old_amount - new_amount > account.balance)
      return { success: false, errors: [ "Insufficient balance for update" ] }
    end

    if transaction.update(transaction_params)
      adjust_balance(account, transaction, old_amount)
      { success: true, transaction: transaction }
    else
      { success: false, errors: transaction.errors.full_messages }
    end
  end

  def self.destroy_transaction(account, transaction)
    adjust_balance(account, transaction, transaction.amount, rollback: true)
    if transaction.destroy
      { success: true }
    else
      { success: false, errors: [ "Could not delete the transaction" ] }
    end
  end

  private

  def self.adjust_balance(account, transaction, previous_amount = 0, rollback: false)
    case transaction.transaction_type
    when "deposit"
      if rollback
        account.update(balance: account.balance - transaction.amount)
      else
        account.update(balance: account.balance + transaction.amount - previous_amount)
      end
    when "withdrawal"
      if rollback
        account.update(balance: account.balance + transaction.amount)
      else
        account.update(balance: account.balance - transaction.amount + previous_amount)
      end
    end
  end
end
