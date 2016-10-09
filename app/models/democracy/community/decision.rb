class Democracy::Community::Decision < ApplicationRecord
  belongs_to :community, :class_name => "Democracy::Community"
  belongs_to :author, :class_name => "User"

  validates :community, presence: true
  validates :author, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :ends_at, presence: true

end
