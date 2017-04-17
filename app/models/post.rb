class Post < ApplicationRecord

  include Likable
  include Commentable

  # the user who wrote the post
  belongs_to :author, :class_name => "User"
  # the profile to which the post has been made
  belongs_to :profile

  # # Scopes
  # returns posts made by friends/user and sent to friends/user
  scope :from_and_to_network_of_user, -> (user) {
    joins(:profile).
    where(
      "posts.author_id = :user_id or " +
      "profiles.user_id = :user_id or " +
      "(posts.author_id IN (:friends_ids) AND " +
      "profiles.user_id IN (:friends_ids))",
      {
        :user_id => user.id,
        :friends_ids => user.friends_ids
      }
    )
  }

  # returns posts ordered by date of creation (most recent first)
  scope :most_recent_first, -> {
    order('posts.created_at DESC')
  }

  # return posts made and received by a given user
  scope :made_and_received_by_user, -> (user) {
    where(author: user).or(Post.where(profile: user.profile))
  }

  # returns posts where author and profile_owner are visible to the user
  scope :readable_by_user, -> (user) {
    joins("INNER JOIN users AS authors ON authors.id = posts.author_id").
    joins(:profile).
    joins("INNER JOIN users AS profile_owners ON profile_owners.id = profiles.user_id").
    where("authors.id = :user_id OR profile_owners.id = :user_id", {
      :user_id => user ? user.id : -1
      }).
    or(
      Post.
      joins("INNER JOIN users AS authors ON authors.id = posts.author_id").
      joins(:profile).
      joins("INNER JOIN users AS profile_owners ON profile_owners.id = profiles.user_id").
      merge( User.viewable_by_user(user, "authors")).
      merge( User.viewable_by_user(user, "profile_owners"))
    )
  }

  # returns posts with default associations needed for showing post
  scope :with_associations, -> {
    includes(:comments).includes(:author).includes(:likes).
    includes(:profile => [:user])
  }

  # # Validations
  validates :author, presence: true
  validates :profile, presence: true
  validates :content, presence: true
  validates :content, length: { maximum: 5000 }
  validate :author_can_post_to_profile, on: :create,
    if: "author.present? and profile.present?"

  def readable_by? user
    if user
      return true if (user.id == self.author.id or user.id == self.profile_owner.id)
    end
    !! (self.author.viewable_by?(user) and self.profile_owner.viewable_by?(user))
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
