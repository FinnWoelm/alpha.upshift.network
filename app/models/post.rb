class Post < ApplicationRecord
  belongs_to :author, :class_name => "User"

  validates :author, presence: true
  validates :content, presence: true
  validates :content, length: { maximum: 5000 }

end
