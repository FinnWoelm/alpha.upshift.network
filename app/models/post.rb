class Post < ApplicationRecord
  belongs_to :author, :class_name => "User"

  default_scope -> { order('created_at DESC') }

  validates :author, presence: true
  validates :content, presence: true
  validates :content, length: { maximum: 5000 }

end
