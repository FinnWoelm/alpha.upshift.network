class Friendship < ApplicationRecord
  belongs_to :initiator, :class_name => "User"
  belongs_to :acceptor, :class_name => "User"

  validates :initiator, presence: true
  validates :acceptor, presence: true
end
