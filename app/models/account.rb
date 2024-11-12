class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions

  validates :account_number, presence: true, uniqueness: true, format: { with: /\A\d{20}\z/, message: "must be 20 digits" }
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  before_validation :generate_account_number, on: :create
  after_initialize :set_default_balance, if: :new_record?

  private

  def generate_account_number
    self.account_number ||= loop do
      random_number = Array.new(20) { rand(10) }.join
      break random_number unless self.class.exists?(account_number: random_number)
    end
  end

  def set_default_balance
    self.balance ||= 0
  end
end
