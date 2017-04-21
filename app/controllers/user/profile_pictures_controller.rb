class User::ProfilePicturesController < ApplicationController
  before_action :current_user

  def show
    user = User.find_by_username(params[:username])
    size = params[:size]

    if user and user.viewable_by?(@current_user)
      expires_in 365.days
      fresh_when user.profile_picture.updated_at, public: false
      send_file(
        user.profile_picture.path(size),
        filename: "#{user.username}_#{size}.jpg",
        type: "image/jpeg",
        disposition: 'inline'
      )
    else
      head 404, content_type: "text/html"
    end
  end
end
