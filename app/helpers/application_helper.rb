module ApplicationHelper

  # renders a timestamp
  def render_timestamp timestamp
    "#{time_ago_in_words timestamp} ago"
  end

  # renders the like action
  def like_action object, style
    render :partial => "likes/like_#{style}", locals: {object: object}
  end

  # renders the unlike action
  def unlike_action object, style
    render :partial => "likes/unlike_#{style}", locals: {object: object}
  end

  # creates a link with text for a given path, highlighting nav element if active
  def nav_link link_text, link_path, link_controller = nil
    if link_controller
      is_active = (controller.controller_path == link_controller)
    else
      is_active = current_page?(link_path)
    end
    link_to link_text, link_path, class: "waves-effect " + (is_active ? 'active' : '')
  end

end
