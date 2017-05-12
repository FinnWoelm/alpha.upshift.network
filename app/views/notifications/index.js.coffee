<% @notifications.each do |notification| %>
$(".notification").last().after(
  '<%= escape_javascript (render notification) %>'
)
<% end %>

# Initialize new toopltips & dropdowns
Application.init_new_tooltips()
Application.init_new_dropdowns()
