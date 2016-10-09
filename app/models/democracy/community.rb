class Democracy::Community < ApplicationRecord

  has_many :decisions, -> { includes(:author) }, dependent: :destroy,
    :class_name => "Democracy::Community::Decision"

  validates :name, presence: true

end
