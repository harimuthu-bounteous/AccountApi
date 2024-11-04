class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :amount, :transaction_type, :created_at
end
