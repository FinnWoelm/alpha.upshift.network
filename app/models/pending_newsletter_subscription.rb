class PendingNewsletterSubscription < ApplicationRecord
  has_secure_token :confirmation_token

  # # Validations
  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, format: { with: /\A.+@.+\..+\z/,
    message: "seems incorrect" }
  validates :name, presence: true
  validates :ip_address, presence: true
  validates :signup_url, presence: true
  validates :confirmation_token, presence: true

end
