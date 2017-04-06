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

  ### nav_link ###
  # Creates a link with text for a given path, highlighting nav element if
  # active.
  #
  # The following options exist:
  # controller: If a controller is specified, then the link will be marked if
  #             the current page is rendered by that controller
  # classes: Add css classes to the link
  # data: Add data-attribute to the link
  # icon: Add an icon to the link
  # wrap_text: wrap the nav text into a span that prevents overflow and line
  #            wrapping if the nav text exceeds the width of the side nav
  def nav_link text, path, options

    options.reverse_update({
      :wrap_text => true
    })

    if options[:controller]
      is_active = (controller.controller_path == options[:controller])
    else
      is_active = current_page?(path)
    end

    if options[:wrap_text]
      text = "<span class='content'>".html_safe + text + "</span>".html_safe
    end

    if options[:icon]
      text = "<i class='mdi mdi-#{options[:icon]}'></i>".html_safe + text
    end

    "<li>".html_safe +
    link_to(text, path,
      class: "waves-effect" + (is_active ? ' active' : '') + (options[:classes] ? " #{options[:classes]}" : ""),
      :data => options[:data]) +
    "</li>".html_safe
  end

  # infinity_scroll loads the next page of records automatically when the
  # infinity_scroll div scrolls into view
  def infinity_scroll records
    # if there is no next page, do not display anything
    return if records.next_page.nil?

    # only use infinity scroll (js-enabled) when page and anchor params are
    # not manually set by user
    render :partial => "infinity_scroll/single_page",
            locals: {
              records: records,
              direction: :next,
              use_javascript: (params[:page].nil? and params[:anchor].nil?)
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
