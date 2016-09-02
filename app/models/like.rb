class Like < ApplicationRecord

  def self.likable_types
    return ["Post", "Comment"]
  end

  belongs_to :liker, :class_name => "User"
  belongs_to :likable, polymorphic: true, counter_cache: true

  validates :liker, presence: true
  validates :likable_id, presence: true
  validates :likable_type, presence: true
  validates :likable_type, inclusion: { in: likable_types,
    message: "%{value} is not a valid likable type" }

  validate :like_is_unique_for_user_and_content,
    if: "liker.present? and likable_id.present? and likable_type.present?"

  # makes sure that there is no previous like for the same content by the same
  # user
  def like_is_unique_for_user_and_content
    if Like.find_by likable_id: self.likable_id, likable_type: self.likable_type, liker: self.liker
      errors[:base] << "You have already liked this #{self.likable_type.downcase}"
    end
  end

end
