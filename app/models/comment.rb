class Comment < ApplicationRecord
  belongs_to :author, :class_name => "User"
  belongs_to :post

  validate :author_must_be_able_to_see_post, on: :create
  validates :author, presence: true
  validates :post, presence: true
  validates :content, presence: true
  validates :content, length: { maximum: 1000 }

  def author_must_be_able_to_see_post
    if not post.can_be_seen_by? author
      errors[:base] << "An error occurred. " +
        "Either the post never existed, it does not exist anymore, " +
        "or the author's profile privacy settings have changed."
    end
  end
  
end
