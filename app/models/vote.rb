class Vote < ApplicationRecord

  def self.votable_types
    ["Democracy::Community::Decision"]
  end

  # # Associations
  belongs_to :voter, :class_name => "User"
  belongs_to :votable, polymorphic: true

  # # Accessors
  enum vote: [ :upvote, :downvote ]

  # # Validations
  validates :voter, presence: true
  validates :votable_id, presence: true
  validates :votable_type, presence: true
  validates :votable_type, inclusion: { in: votable_types,
    message: "%{value} is not a valid likable type" }

  validate :vote_must_be_unique_for_user_and_content,
    if: Proc.new { |v| v.voter.present? and v.votable_id.present? and v.votable_type.present? },
    on: :create
  validate :voter_must_not_change, on: :update
  validate :votable_must_not_change, on: :update

  # # Callbacks
  # Keep vote counts on votable accurate
  after_create { votable.increase_votes_count(vote) }
  after_update { votable.modify_votes_count(vote, vote_before_last_save) }
  after_destroy { votable.decrease_votes_count(vote) }

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

    # Validation: Voter must remain when updating
    def voter_must_not_change
      if self.changed.include?("voter_id")
        errors[:voter] << "cannot be modified for an existing vote"
      end
    end

    # Validation: Votable must remain when updating
    def votable_must_not_change
      if self.changed.include?("votable_type") or self.changed.include?("votable_id")
        errors[:votable] << "cannot be modified for an existing vote"
      end
    end

end
