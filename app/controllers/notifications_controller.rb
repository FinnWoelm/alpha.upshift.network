class NotificationsController < ApplicationController
  before_action :authorize

  def index
    @notifications =
      Notification.
      for_user(@current_user)
  end

  def mark_seen
    Notification::Subscription.
    find_by(
      :subscriber => @current_user,
      :notification_id => params[:notification_id]
    ).
    touch(:seen_at)

    respond_to do |format|
      format.html { redirect_to notifications_path }
      format.js { @notification_id = params[:notification_id] }
    end
  end
end
