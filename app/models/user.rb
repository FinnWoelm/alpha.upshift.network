class User < ApplicationRecord
  has_secure_password

  validates :username, format: { with: /\A[a-zA-Z0-9_]+\z/ }
end
