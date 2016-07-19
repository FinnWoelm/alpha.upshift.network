class FriendshipRequest < ApplicationRecord
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"

  validates :sender, presence: true
  validates :recipient, presence: true
end
