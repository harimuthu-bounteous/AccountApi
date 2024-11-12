# spec/controllers/accounts_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::AccountsController, type: :controller do
  let(:user) { User.create(username: "testuser1", email: "testuser1@email.com", password: "test123", role: "user") }
  let(:admin) { User.create(username: "admin", email: "admin@email.com", password: "admin", role: "admin") }
  let(:account) { Account.create(user: user, account_number: "46861569809056088756", balance: 0.0) }
  let(:valid_token) { JwtService.encode(user_id: user.id) } # Generate a valid token

  before do
    request.headers['Authorization'] = "Bearer #{valid_token}"
    @user = user
    @token = valid_token
    @headers = { Authorization: "Bearer #{@token}" }
    allow(controller).to receive(:current_user).and_return(user)
  end

  # ✅
  describe "GET #index" do
    context "as an admin user" do
      before do
        request.headers["Authorization"] = "Bearer #{@token}"
        allow(controller).to receive(:authorize_admin!).and_return(true)
      end

      it "returns a list of accounts" do
        2.times { Account.create(user: User.create(username: "user_#{rand(1000)}", email: Faker::Internet.unique.email, password: "password")) }
        get :index
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(2)
      end
    end
  end

  # ✅
  describe "GET #show =>" do
    context "when the account belongs to the user =>" do
      before do
        request.headers["Authorization"] = "Bearer #{@token}"
      end

      it "returns the account" do
        get :show, params: { account_number: account.account_number }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["account_number"]).to eq(account.account_number)
      end
    end

    context "when the account does not belong to the user =>" do
      let(:other_user) { User.create(username: "other_user", email: Faker::Internet.unique.email, password: "password", role: "user") }
      let(:other_account) { Account.create(user: other_user, account_number: "46861569809056088786", balance: 0.0) }

      before do
        allow(controller).to receive(:authenticate_user).and_return(true)
      end

      it "returns forbidden status" do
        get :show, params: { account_number: other_account.account_number }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST #create" do
    let(:user) { User.create(username: "new_user", email: "new_user@example.com", password: "password") }

    context "when account creation is successful" do
      it "creates a new account and returns 201 status" do
        expect { post :create, params: {} }.to change(Account, :count).by(1)

        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response["account_number"]).to be_present
        expect(json_response["balance"]).to eq("0.0")
        expect(json_response["user"]["username"]).to eq(user.username)
        expect(json_response["user"]["email"]).to eq(user.email)
      end
    end

    context "when account creation fails" do
      it "returns an error message and 422 status" do
        allow_any_instance_of(AccountService).to receive(:create_account).and_raise(ActiveRecord::RecordInvalid)

        post :create

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to include("Account creation failed")
      end
    end
  end

  describe "PUT #update" do
    context "when updating balance" do
      it "updates the account balance" do
        put :update, params: { account_number: account.account_number, account: { balance: 100.0 } }
        expect(response).to have_http_status(:ok)
        expect(account.reload.balance).to eq(100.0)
      end
    end

    context "when update fails" do
      it "returns error" do
        allow_any_instance_of(AccountService).to receive(:update_account).and_raise(ActiveRecord::RecordInvalid)
        put :update, params: { account_number: account.account_number, account: { balance: -1 } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:authenticate_user).and_return(true)
      allow(controller).to receive(:authorize_user!).and_return(true)
    end

    context "when account is successfully deleted" do
      it "deletes the account" do
        delete :destroy, params: { account_number: account.account_number }
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when account deletion fails" do
      it "returns error" do
        allow_any_instance_of(AccountService).to receive(:destroy_account).and_raise("Error destroying account")
        delete :destroy, params: { account_number: account.account_number }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end
end
