class Post < ApplicationRecord

  include Likable
  include Commentable

  # the user who wrote the post
  belongs_to :author, :class_name => "User"
  # the profile to which the post has been made
  belongs_to :profile

  scope :most_recent_first,
    -> { order('posts.created_at DESC') }
  scope :with_associations,
    -> { includes(:comments).includes(:author).includes(:likes) }

  # # Validations
  validates :author, presence: true
  validates :profile, presence: true
  validates :content, presence: true
  validates :content, length: { maximum: 5000 }
  validate :author_can_post_to_profile, on: :create,
    if: "author.present? and profile.present?"

  def readable_by? user
    !! self.author.viewable_by?(user)
  end

  # whether the post can be deleted by a given user
  def deletable_by? user
    return false unless user
    return self.author.id == user.id
  end

  # sets the profile owner and profile (if profile_owner is a User)
  def profile_owner=(user)
    @profile_owner = User.to_user(user)
    if @profile_owner.is_a? User
      self.profile = @profile_owner.profile
    end
  end

  # returns the owner (user) of the profile to which the post has been made
  def profile_owner
    if @profile_owner.present?
      @profile_owner
    else
      self.profile.try(:user)
    end
  end

  private

    # validate that author can post to the profile
    def author_can_post_to_profile
      if not profile_owner.viewable_by? author
        errors.add :profile, "does not exist or is private"
      end
    end

end
