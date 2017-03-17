private_conversation = new PrivateConversation("<%= @private_conversation.id %>")

private_conversation.add_previous_messages([
<% @private_messages.sort_by(&:id).reverse.each do |private_message| %>
  [<%= private_message.id %>,
  "<%= escape_javascript render(private_message) %>"],
<% end %>
])

# Initialize new toopltips
Application.init_new_tooltips()
