# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    username { "testuser1" }
    email { "testuser1@email.com" }
    password { "test123" }
    role { :user }  # Or :admin if needed for testing admin functionality

    # trait :admin do
    #   role { :admin }
    # end
  end

  factory :admin do
    username { "admin" }
    email { "admin@email.com" }
    password { "admin" }
    role { :admin }
  end
end
