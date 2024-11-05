class AddDefaultBalanceToAccounts < ActiveRecord::Migration[7.2]
  def change
    change_column_default :accounts, :balance, 0
  end
end
