class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def authorize
    redirect_to '/login' and return unless current_user
    redirect_to confirmation_reminder_registration_path unless current_user.confirmed_registration
  end

  # Returns a shallow path for a given object, such as decision_path for
  # Democracy::Community::Decision
  def shallow_path_to object
    Rails.application.routes.url_helpers.send("#{object.class.to_s.split("::").last.downcase}_path", object)
  end

  # Get the user's private conversations ordered by most recent,
  # include the most recent message
  def get_recent_conversations_for_sidenav
    @private_conversations_in_sidenav =
      PrivateConversation.
      for_user(@current_user).
      with_unread_message_count_for(@current_user)
  end
  helper_method :get_recent_conversations_for_sidenav

end
