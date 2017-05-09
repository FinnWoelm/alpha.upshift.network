class NotificationsController < ApplicationController
  before_action :authorize

  def index
    @notifications =
      Notification.
      for_user(@current_user)
  end
end
