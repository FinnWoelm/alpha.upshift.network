class Account < ApplicationRecord
  has_secure_password

  # before_destroy callback must come before associations for it to be executed
  # prior to deleting associated objects.
  # See: https://github.com/rails/rails/issues/3458
  # Aborts destruction if current password does not match user's password
  before_destroy do
    current_password_matches_password
    throw(:abort) if self.errors[:current_password].any?
  end

  has_one :user, dependent: :destroy, inverse_of: :account

  # # Accessors
  attr_accessor :current_password
  attr_accessor :update_password

  # Email
  validates :email, presence: true
  validates :email, format: {
    with: /\A\S+@\S+\.\S+\z/,
    message: "seems invalid"
  }
  validates :email,
    uniqueness: { :case_sensitive => false }

  # Password
  validates :password,
    presence: true,
    if: Proc.new{ |a| !! a.update_password }
  validates :password,
    length: { in: 8..50 },
    unless: Proc.new { |a| a.password.nil? }

  # validate that the supplied password matches the actual password
  validate :current_password_matches_password, on: :update


  private

    # validate that the supplied password matches the actual password
    def current_password_matches_password
      # authenticate against database
      if not Account.find(id).authenticate(current_password)
        errors.add :current_password, "does not match your current password"
      end
    end

end
