class Comment < ApplicationRecord

  include Likable

  belongs_to :author, :class_name => "User"
  belongs_to :post

  validates :author, presence: true
  validates :post, presence: true
  validates :content, presence: true
  validates :content, length: { maximum: 1000 }

  validate :author_must_be_able_to_see_post, on: :create,
    if: "author.present? and post.present?"

  def author_must_be_able_to_see_post
    if not post.can_be_seen_by? author
      errors[:base] << "An error occurred. " +
        "Either the post never existed, it does not exist anymore, " +
        "or the author's profile privacy settings have changed."
    end
  end

  # whether the comment can be deleted by a given user
  def can_be_deleted_by? user
      # no user
      return false unless user

      # the user is the author of the comment
      return self.author.id == user.id
  end

end
