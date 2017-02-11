private_conversation = new PrivateConversation("<%= @private_conversation.id %>")

private_conversation.add_message_from_user_compose_form(
  <%= @private_message.id %>,
  "<%= escape_javascript render @private_message %>"
)

# Update PrivateConversationPreview
PrivateConversationPreview.add(
  '<%= @private_conversation.id %>',
  '<%= escape_javascript @private_conversation.updated_at.exact %>',
  '<%= escape_javascript nav_link_conversation_preview(@private_conversation) %>',
  false
)

# Initialize new toopltips
Application.init_new_tooltips()
