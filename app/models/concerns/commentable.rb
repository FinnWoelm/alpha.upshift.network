module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments,
      -> { includes(:author).includes(:likes) },
      {as: :commentable, dependent: :delete_all}
  end

end
