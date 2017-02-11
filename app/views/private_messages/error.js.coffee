<%
  # was the conversation deleted?
  if @private_conversation.nil? %>

    private_conversation = new PrivateConversation("<%= params[:private_conversation_id] %>")

    private_conversation.mark_deleted("<%= escape_javascript render(partial: 'conversation_has_been_deleted.html.erb') %>")
    BackgroundJob.stop("private-conversation-fetch-new-messages")

    # Initialize new toopltips
    Application.init_new_tooltips()

<%
  # just 'ordinary' validation errors
  else %>

    validator = new FormValidator("#new_private_message", "private_message")
    validator.clear_errors()

    <%
    @private_message.errors.messages.each do |field_name, error_messages|

      error_messages.each do |error_message|
    %>

    validator.add_error("<%= escape_javascript field_name.to_s %>", "<%= escape_javascript error_message %>")

    <%
      end
    end
    %>

<% end %>
