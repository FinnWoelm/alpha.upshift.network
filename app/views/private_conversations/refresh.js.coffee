<% @private_conversations.sort_by(&:updated_at).each do |private_conversation| %>
PrivateConversationPreview.add(
  '<%= private_conversation.id %>',
  '<%= escape_javascript private_conversation.updated_at.exact %>',
  '<%= escape_javascript nav_link_conversation_preview(private_conversation) %>',
  true
)
<% end %>
