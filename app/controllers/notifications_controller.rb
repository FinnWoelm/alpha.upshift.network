class NotificationsController < ApplicationController
  before_action :authorize

  def index
    @notifications =
      Notification.
      for_user(@current_user).
      paginate_with_anchor(
        :page => params[:page],
        :anchor => params[:anchor] || Time.zone.now,
        :anchor_column => "notification_actions.created_at",
        :anchor_orientation => :less_than
      )
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

  def mark_all_seen
    Notification::Subscription.
    where(
      :subscriber => @current_user,
      :notification => Notification.for_user(@current_user).unseen_only.ids.uniq
    ).
    update_all(:seen_at => Time.zone.now)

    redirect_to notifications_path
  end
end
