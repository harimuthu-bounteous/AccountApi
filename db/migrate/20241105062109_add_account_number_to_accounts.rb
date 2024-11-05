class AddAccountNumberToAccounts < ActiveRecord::Migration[7.2]
  def change
    add_column :accounts, :account_number, :string, null: false
    add_index :accounts, :account_number, unique: true
  end
end
