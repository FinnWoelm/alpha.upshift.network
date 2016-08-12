class Comment < ApplicationRecord

  include Likable

  belongs_to :author, :class_name => "User"
  belongs_to :post

  default_scope -> { order('comments.created_at ASC') }

  validates :author, presence: true
  validates :post, presence: true
  validates :content, presence: true
  validates :content, length: { maximum: 1000 }

  # Validation: User can only write comments on posts that they can see
  validate :author_must_be_able_to_see_post, on: :create,
    if: "author.present? and post.present?"

  # whether the comment can be deleted by a given user
  def deletable_by? user
      return false unless user
      return self.author.id == user.id
  end

  private

    # Validation: User can only write comments on posts that they can see
    def author_must_be_able_to_see_post
      if not post.readable_by? author
        errors[:base] << "An error occurred. " +
          "Either the post never existed, it does not exist anymore, " +
          "or the author's profile privacy settings have changed."
      end
    end

end
