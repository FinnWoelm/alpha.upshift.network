<% @posts.each do |post| %>
$(".post-wrapper").last().after(
  '<%= escape_javascript (render post) %>'
)
<% end %>

# Initialize new toopltips & dropdowns
Application.init_new_tooltips()
Application.init_new_dropdowns()

# Initialize (new) comment forms
Comment.initialize_new_forms()
