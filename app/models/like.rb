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

end
