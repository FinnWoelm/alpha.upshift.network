class Democracy::Community::Decision < ApplicationRecord

  include Commentable
  include Votable

  belongs_to :community, :class_name => "Democracy::Community"
  belongs_to :author, :class_name => "User"

  validates :community, presence: true
  validates :author, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :ends_at, presence: true

  # Can the decision be seen & read by a give user?
  def readable_by? user
    true
  end

end
