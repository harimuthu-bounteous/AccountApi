class ChangeTransactionTypeToIntegerInTransactionsModel < ActiveRecord::Migration[7.2]
  def up
    change_column :transactions, :transaction_type, :integer, using: 'transaction_type::integer', null: false
  end

  def down
    change_column :transactions, :transaction_type, :string
  end
end
