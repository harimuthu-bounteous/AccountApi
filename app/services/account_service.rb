class AccountService
  def initialize(user, account_params)
    @user = user
    @account_params = account_params
  end

  # Create an account for the user
  def create_account
    @account = @user.accounts.build(@account_params)
    @account.balance ||= 0 # Default to 0 if balance is not provided

    if @account.save
      @account
    else
      raise ActiveRecord::RecordInvalid.new(@account)
    end
  end

  # Update an existing account
  def update_account(account)
    if account.update(@account_params)
      account
    else
      raise ActiveRecord::RecordInvalid.new(account)
    end
  end

  # Destroy an existing account
  def destroy_account(account)
    account.destroy
  rescue => e
    raise "Error destroying account: #{e.message}"
  end
end
