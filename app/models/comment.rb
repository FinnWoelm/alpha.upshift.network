class Comment < ApplicationRecord

  def self.commentable_types
    ["Post", "Democracy::Community::Decision"]
  end

  include Likable

  belongs_to :author, :class_name => "User", optional: false
  belongs_to :commentable, polymorphic: true, optional: false

  default_scope -> { order('comments.created_at ASC') }

  validates :commentable_type, inclusion: { in: commentable_types,
    message: "%{value} is not a valid commentable type" }
  validates :content, presence: true
  validates :content, length: { maximum: 1000 }

  # Validation: User can only write comments on posts that they can see
  validate :author_must_be_able_to_see_commentable, on: :create,
    if: "author.present? and commentable.present?"

  # whether the comment can be deleted by a given user
  def deletable_by? user
      return false unless user
      return self.author.id == user.id
  end

  private

    # Validation: User can only write comments on posts that they can see
    def author_must_be_able_to_see_commentable
      if not commentable.readable_by? author
        errors[:base] << "An error occurred. " +
          "Either the #{self.commentable_type.downcase} never existed, " +
          "it does not exist anymore, " +
          "or you do not have permission to view it."
      end
    end

end
