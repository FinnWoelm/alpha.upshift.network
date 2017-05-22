<% @results.each do |result| %>
$(".search_result").last().after(
  '<%= escape_javascript (render(partial: "result", object: result)) %>'
)
<% end %>

# Initialize new toopltips & dropdowns
Application.init_new_tooltips()
Application.init_new_dropdowns()
