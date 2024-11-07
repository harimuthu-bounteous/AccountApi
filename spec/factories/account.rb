# factories/accounts.rb
FactoryBot.define do
  factory :account do
    balance { 0.0 }
    account_number { Faker::Bank.account_number(digits: 20) }

    association :user, factory: :user  # This associates a user with the account

    after(:build) do |account|
      account.user ||= FactoryBot.create(:user, email: Faker::Internet.unique.email)  # Ensure unique email for each user
    end
  end
end
