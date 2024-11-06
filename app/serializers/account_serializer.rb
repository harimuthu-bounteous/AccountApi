class AccountSerializer < ActiveModel::Serializer
  attributes :id, :account_number, :balance,  :created_at

  belongs_to :user, serializer: UserSerializer
end
