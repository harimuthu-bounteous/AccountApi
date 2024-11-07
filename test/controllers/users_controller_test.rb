require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
end

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should register user with valid params" do
    post register_url, params: { user: { email: "test@example.com", password: "password", username: "testuser" } }
    assert_response :created
    json_response = JSON.parse(response.body)
    assert json_response["user"]
    assert json_response["token"]
  end

  test "should not register user with invalid params" do
    post register_url, params: { user: { email: "", password: "", username: "" } }
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response["errors"]
  end

  test "should handle ActiveRecord::RecordInvalid exception" do
    UserService.stub(:register_user, ->(_) { raise ActiveRecord::RecordInvalid.new(User.new) }) do
      post register_url, params: { user: { email: "test@example.com", password: "password", username: "testuser" } }
      assert_response :unprocessable_entity
      json_response = JSON.parse(response.body)
      assert json_response["errors"]
    end
  end
end
