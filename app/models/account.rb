class Account < ApplicationRecord
  has_secure_password
  has_one :user, dependent: :destroy, inverse_of: :account

  # Email
  validates :email, presence: true
  validates :email, format: {
    with: /\A\S+@\S+\.\S+\z/,
    message: "seems invalid"
  }
  validates :email,
    uniqueness: { :case_sensitive => false }

  # Password
  validates :password, confirmation: true
  validates :password,
    length: { in: 8..50 },
    unless: Proc.new { |u| u.password.nil? }

end
