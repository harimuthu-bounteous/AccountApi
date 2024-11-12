# spec/controllers/transaction_controller_spec.rb
require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }
  let(:account) { create(:account, user: user) }
  let(:transaction1) { create(:transaction, account: account, amount: 100.0, transaction_type: :deposit) }
  let(:transaction2) { create(:transaction, account: account, amount: 50.0, transaction_type: :withdrawal) }
  let(:valid_token) { JwtService.encode(user_id: user.id) }

  before do
    request.headers['Authorization'] = "Bearer #{valid_token}"
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "POST #create" do
    context "when the transaction is successful" do
      it "creates a new transaction" do
        post :create, params: { account_number: account.account_number, transaction: { amount: 100.0, transaction_type: :deposit } }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to have_key("id")
      end

      it "fails to create a new transaction with invalid account number" do
        post :create, params: { account_number: "invalid_account_number", transaction: { amount: 100.0, transaction_type: :deposit } }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end

  describe "GET #show_transactions" do
    context "when the account exists" do
      it "returns a list of transactions for the account" do
        # Add transactions to the account
        transaction1
        transaction2

        get :show_transactions, params: { account_number: account.account_number }

        expect(response).to have_http_status(:ok)

        # Parse the JSON response
        json_response = JSON.parse(response.body)

        expect(json_response.size).to eq(2)
        expect(json_response[0]["amount"].to_f).to eq(transaction1.amount)
        expect(json_response[1]["amount"].to_f).to eq(transaction2.amount)
      end
    end

    context "when the account does not exist" do
      it "returns a not found error" do
        get :show_transactions, params: { account_number: "nonexistent" }

        expect(response).to have_http_status(:not_found)

        # Parse the JSON response for error messages
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to include("Account not found")
      end
    end
  end
end
