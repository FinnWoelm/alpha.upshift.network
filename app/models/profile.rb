class Profile < ApplicationRecord

  # # Associations
  belongs_to :user, inverse_of: :profile

  # # Validations
  validates :user, presence: true

end
