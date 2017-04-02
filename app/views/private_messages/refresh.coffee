private_conversation = new PrivateConversation("<%= @private_conversation.id %>")

private_conversation.add_new_messages([
<% @private_messages.sort_by(&:id).each do |private_message| %>
  [<%= private_message.id %>,
  "<%= escape_javascript render(private_message) %>"],
<% end %>
])

# Update PrivateConversationPreview
PrivateConversationPreview.add(
  '<%= @private_conversation.id %>',
  '<%= escape_javascript @private_conversation.updated_at.exact %>',
  '<%= escape_javascript nav_link_conversation_preview(@private_conversation) %>',
  false
)

# Initialize new toopltips
Application.init_new_tooltips()
