require 'rails_helper'

RSpec.describe "Users API", type: :request do
  let(:user_params) do
    {
      user: {
        username: "testuser",
        email: "testuser@example.com",
        password: "password"
      }
    }
  end
end
