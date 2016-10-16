class Vote < ApplicationRecord

  def self.votable_types
    ["Democracy::Community::Decision"]
  end

  # # Associations
  belongs_to :voter, :class_name => "User"
  belongs_to :votable, polymorphic: true, counter_cache: true

  # # Accessors
  enum vote: [ :upvote, :downvote ]

  # # Validations
  validates :voter, presence: true
  validates :votable_id, presence: true
  validates :votable_type, presence: true
  validates :votable_type, inclusion: { in: votable_types,
    message: "%{value} is not a valid likable type" }

  validate :vote_must_be_unique_for_user_and_content,
    if: "voter.present? and votable_id.present? and votable_type.present?"

  private

    # validates that there is no existing like for this content by this user
    def vote_must_be_unique_for_user_and_content
      if Vote.exists?(
          votable_id: self.votable_id,
          votable_type: self.votable_type,
          voter: self.voter )
        errors[:base] << "You have already voted on this #{self.votable_type.downcase}"
      end
  end

end
