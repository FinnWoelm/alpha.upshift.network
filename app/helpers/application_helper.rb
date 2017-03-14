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
  def nav_link link_text, link_path, link_controller = nil, link_classes = nil, link_data = nil
    if link_controller
      is_active = (controller.controller_path == link_controller)
    else
      is_active = current_page?(link_path)
    end
    link_to link_text, link_path,
      class: "waves-effect " + (is_active ? 'active' : '') + (link_classes ? " #{link_classes}" : ""),
      :data => link_data
  end

  # infinity_scroll loads the next page of records automatically when the
  # infinity_scroll div scrolls into view
  def infinity_scroll records
    # if there is no next page, do not display anything
    return if records.next_page.nil?

    render :partial => "infinity_scroll/single_page",
            locals: {
              records: records,
              direction: :next,
              use_javascript: true
            }
  end

  # infinity_scroll_fallback loads the previous page of records only upon click
  # this is a fallback method for when a user has JS disabled (if JS is enabled,
  # the user should never get into a situation where they need to load previous
  # records)
  def infinity_scroll_fallback records
    # if there is no next page, do not display anything
    return if records.previous_page.nil?

    render :partial => "infinity_scroll/single_page",
            locals: {
              records: records,
              direction: :previous,
              use_javascript: false
            }
  end

end
