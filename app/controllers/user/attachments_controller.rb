class User::AttachmentsController < ApplicationController
  before_action :current_user

  def show
    user = User.find_by_username(params[:username])
    size = params[:size]
    attachment = params[:attachment]

    if user and user.send(attachment.to_sym).present? and user.viewable_by?(@current_user)
      expires_in 365.days
      fresh_when user.send(attachment.to_sym).updated_at, public: false
      send_file(
        user.send(attachment.to_sym).path(size),
        filename: "#{user.username}_#{attachment}_#{size}.jpg",
        type: "image/jpeg",
        disposition: 'inline'
      )
    else
      head 404, content_type: "text/html"
    end
  end
end
