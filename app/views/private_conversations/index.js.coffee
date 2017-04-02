<% @private_conversations.sort_by(&:updated_at).reverse.each do |private_conversation| %>
PrivateConversationPreview.add_previous_conversation(
  '<%= private_conversation.id %>',
  '<%= escape_javascript private_conversation.updated_at.exact %>',
  '<%= escape_javascript (render private_conversation) %>'
)
<% end %>
