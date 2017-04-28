module ApplicationHelper

  # Renders an options dropdown button that activates the element with the given
  # id. This is used for the administrative actions button for post, comment,
  # private conversation, etc...
  def options_dropdown_button object, &dropdown_content
    dropdown_button(
      "#{object.model_name.to_s.downcase}-#{object.id}",
      {
        :dropdown => {
          :constrainwidth => false,
          :belowOrigin => true,
          :alignment => 'right',
        },
        :trigger => {
          :class => "btn-flat",
          :content => "<i class='mdi mdi-chevron-down'></i>".html_safe
        },
        :tooltip => {
          :tooltip => "Show Options",
          :position => "left",
          :delay => 50
        }
      },
      &dropdown_content
    )
  end

  # Renders a dropdown button that accepts the given options and renders the
  # content inside the drowdown toggle
  def dropdown_button identifier, options, &dropdown_content

    options.reverse_update({
      :dropdown => {},
      :trigger => {},
      :tooltip => {}
    })

    identifier ||= "r#{Random.rand.to_s[2..-1]}"

    options[:dropdown].reverse_update({
      :activates => "dropdown-#{identifier}",
      :constrainwidth => false,
      :belowOrigin => true,
      :alignment => 'left',
      :hover => false
    })

    if options[:tooltip][:tooltip].present?
      options[:tooltip].reverse_update({
        :position => "right",
        :delay => 50
      })
      (options[:trigger][:class] += " tooltipped")
    end

    render :partial => "shared/dropdown_button",
      locals: {
        classes: options[:trigger][:class],
        data: options[:dropdown].update(options[:tooltip]),
        trigger_content: Proc.new{ options[:trigger][:content] },
        dropdown_content: dropdown_content
      }
  end

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

  # links to the profile of a given user
  def link_to_profile user, options = {}, &link_content
    href = user_path(user) if user.viewable_by?(@current_user)

    content_tag "a", href: href, class: options[:class], data: options[:data], title: options[:title] do
      link_content.call
    end
  end

  # renders the user's profile picture
  def profile_picture user, size = nil
    size ||= user.profile_picture.options[:default_style]

    if not user.profile_picture.present?
      user.profile_picture.options[:default_url]
    elsif user.viewable_by?(@current_user) or not user.profile_picture.present?
      user.profile_picture.url(size)
    else
      "data:image/jpeg;base64," + Base64.encode64(File.read(user.profile_picture.path(size)))
    end
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
      text = "<div class='single_line prevent_overflow'>".html_safe + text + "</div>".html_safe
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
