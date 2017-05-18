<% @friendship_requests.each do |friendship_request| %>
$(".friendship_request").last().after(
  '<%= escape_javascript (render friendship_request) %>'
)
<% end %>

# Initialize new toopltips & dropdowns
Application.init_new_tooltips()
Application.init_new_dropdowns()
