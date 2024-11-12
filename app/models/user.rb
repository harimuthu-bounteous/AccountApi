class User < ApplicationRecord
  has_secure_password
  enum :role, { user: 0, admin: 1 }
  # enum :role, { admin: 0, user: 1 }, _prefix: :role
  has_many :accounts, dependent: :destroy
  validates :email, presence: true, uniqueness: true
end
