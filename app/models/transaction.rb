class Transaction < ApplicationRecord
  belongs_to :account

  enum transaction_type: { deposit: 0, withdrawal: 1 }
  # enum :transaction_type, { deposit: 0, withdrawal: 1 }, _prefix: :transaction_type

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_type, presence: true, inclusion: { in: transaction_types.keys }
end
