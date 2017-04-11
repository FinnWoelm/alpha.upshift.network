class Profile < ApplicationRecord

  # # Associations
  belongs_to :user, inverse_of: :profile
  has_many :posts, dependent: :destroy

  # # Validations
  validates :user, presence: true

end
