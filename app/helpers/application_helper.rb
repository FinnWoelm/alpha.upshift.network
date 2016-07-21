module ApplicationHelper

  # renders a timestamp
  def render_timestamp timestamp
    return timestamp.strftime('%a, %B %e, %Y at %l:%M%P')
  end

end
