# spec/controllers/users_controller_spec.rb
require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "POST /auth/register" do
    context "when registration is successful" do
      it "creates a new user and returns a token" do
        post :register, params: { user: { email: "testuser1@email.com", password: "test123", username: "testuser1" } }    #    --> Without FactoryBot
        # post :register, params: { user: FactoryBot.attributes_for(:user) }                                            --> With FactoryBot without configuring FactoryBotRails in spec_helper.rb
        # post :register, params: { user: attributes_for(:user) }                                                  #    --> With FactoryBot and configuring FactoryBotRails in spec_helper.rb

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to have_key("token")
        expect(JSON.parse(response.body)["user"]["email"]).to eq("testuser1@email.com")
        expect(JSON.parse(response.body)["user"]["username"]).to eq("testuser1")
      end
    end

    context "when registration fails" do
      it "returns errors" do
        # Attempt to create a user without required fields
        # post :register, params: { user: { email: "" } }                                       --> Without FactoryBot
        # post :register, params: { user: FactoryBot.attributes_for(:user, email: nil) }        --> With FactoryBot without configuring FactoryBotRails in spec_helper.rb
        post :register, params: { user: attributes_for(:user, email: nil) }            #        --> With FactoryBot and configuring FactoryBotRails in spec_helper.rb

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end

  describe "POST /auth/admin/register" do
    context "when admin registration is successful" do
      it "creates a new admin user and returns a token" do
        # post :register_admin, params: { user: { email: "admin@example.com", password: "password", username: "adminuser" } }
        # post :register_admin, params: { user: FactoryBot.attributes_for(:user, :admin) }
        post :register_admin, params: { user: attributes_for(:user, :admin) }


        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to have_key("token")
        expect(JSON.parse(response.body)["user"]["role"]).to eq("admin")
      end
    end

    context "when admin registration fails" do
      it "returns errors" do
        # Attempt to create an admin user without required fields
        # post :register_admin, params: { user: { email: "" } }
        # post :register_admin, params: { user: FactoryBot.attributes_for(:user, :admin, email: nil) }
        post :register_admin, params: { user: attributes_for(:user, :admin, email: nil) }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end

  describe "POST /auth/login" do
    let!(:user) { create(:user, email: "user@example.com", password: "password") }

    context "when login is successful" do
      it "returns a user object and token" do
        # post :login, params: { email: "user@example.com", password: "password" }

        # user = FactoryBot.create(:user)
        user = create(:user)
        post :login, params: { email: user.email, password: user.password }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key("token")
        expect(JSON.parse(response.body)["user"]["email"]).to eq("testuser1@email.com")
      end
    end

    context "when login fails" do
      it "returns an error for invalid credentials" do
        # post :login, params: { email: "user@example.com", password: "wrongpassword" }

        # FactoryBot.create(:user, email: "wrong@example.com", password: "wrongpassword")
        create(:user, email: "wrong@example.com", password: "wrongpassword")
        post :login, params: { email: "wrong@example.com", password: "incorrectpassword" }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end
end
