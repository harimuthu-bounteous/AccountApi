# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    username { "testuser" }
    email { "testuser@example.com" }
    password { "password" }
    role { :user }  # Or :admin if needed for testing admin functionality

    # trait :admin do
    #   role { :admin }
    # end
  end

  factory :admin do
    username { "admin" }
    email { "admin@example.com" }
    password { "admin" }
    role { :admin }
  end
end
