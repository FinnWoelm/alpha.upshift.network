class Like < ApplicationRecord

  def self.likable_types
    ["Post", "Comment"]
  end

  # # Associations
  belongs_to :liker, :class_name => "User", optional: false
  belongs_to :likable, polymorphic: true, counter_cache: true, optional: false

  # # Validations
  validates :likable_type, inclusion: { in: likable_types,
    message: "%{value} is not a valid likable type" }

  validate :like_must_be_unique_for_user_and_content,
    if: "liker.present? and likable_id.present? and likable_type.present?"

  private

    # validates that there is no existing like for this content by this user
    def like_must_be_unique_for_user_and_content
      if Like.exists?(
          likable_id: self.likable_id,
          likable_type: self.likable_type,
          liker: self.liker )
        errors[:base] << "You have already liked this #{self.likable_type.downcase}"
      end
    end

end
