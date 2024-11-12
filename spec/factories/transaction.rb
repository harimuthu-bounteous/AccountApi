# # spec/factories/transactions.rb
FactoryBot.define do
  factory :transaction do
    account
    amount { 100.0 }
    transaction_type { :deposit }
  end
end
