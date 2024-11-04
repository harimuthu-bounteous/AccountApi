class Transaction < ApplicationRecord
  belongs_to :account
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_type, inclusion: { in: %w[deposit withdrawal] }
end
