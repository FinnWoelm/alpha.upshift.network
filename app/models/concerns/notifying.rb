module Notifying
  extend ActiveSupport::Concern

  # callbacks
  included do
    after_create :create_notification
    after_destroy :destroy_notification
  end

end
