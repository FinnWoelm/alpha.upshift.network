class Post < ApplicationRecord
  belongs_to :author, :class_name => "User"
  has_many :comments, -> { includes :author }, dependent: :destroy

  default_scope -> { includes(:comments).order('created_at DESC') }

  validates :author, presence: true
  validates :content, presence: true
  validates :content, length: { maximum: 5000 }

  def can_be_seen_by? user
    return self.author.profile.can_be_seen_by? user
  end

  # whether the post can be deleted by a given user
  def can_be_deleted_by? user

    # no user
    return false unless user

    # the user is the author of the post
    return self.author.id == user.id
  end

end
