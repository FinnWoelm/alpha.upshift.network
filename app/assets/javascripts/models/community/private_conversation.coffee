class @PrivateConversation

  # Methods
  #
  #/ Static: Public
  #// get_active_conversation: returns an instance of PrivateConversation from
  #//                          the currently visible conversation
  #
  #/ Instance: Public
  #// add_message_from_user_compose_form: adds a message that was entered by the
  #//                                     user
  #// get_preview: returns an instance of PrivateConversationPreview that
  #//              belongs to this instance of PrivateConversation
  #// mark_deleted: marks the conversation as deleted and disables message form
  #
  #/ Instance: Private
  #// add_messages: appends one or multiple messages to the bottom of the chat
  #//               (and moves viewport)
  #// selector: returns the jquery selector for this conversation


  #########################
  # Static Public Methods #
  #########################

  constructor: (@id) ->

  # returns the currently active conversation
  @get_active_conversation: ->
    new PrivateConversation $("div.private_conversation.show").attr("data-conversation-id")


  ###########################
  # Public Instance Methods #
  ###########################

  # adds a message that was entered by the user
  add_message_from_user_compose_form: (message_id, message_html) ->

    # add the message
    @_add_message message_id, message_html

    # mark message as pushed
    @_selector().find("#chat_body .private_message[data-message-id=#{message_id}]").addClass("pushed")

    # clear user compose textarea
    @_selector().find("#compose_message form .materialize-textarea").val("")
    @_selector().find("#compose_message form .materialize-textarea").trigger("autoresize")
    @_selector().find("#compose_message form").trigger('checkform.areYouSure');


  # returns an instance of PrivateConversationPreview that belongs to this
  # instance of PrivateConversation
  get_preview: ->
    return new PrivateConversationPreview @id


  # marks the conversation as deleted and disables message form
  mark_deleted: (deletion_message_html) ->

    # show deletion message
    @_selector().find("#chat_body .section.bottom").before deletion_message_html

    # disable input
    @_selector().find("#compose_message form .materialize-textarea").prop("readonly", true)
    @_selector().find("#compose_message form button[type=submit]").addClass("disabled")


  ############################
  # Private Instance Methods #
  ############################

  # appends a message to the bottom of the chat (and moves viewport)
  _add_message: (message_id, message_html) ->

    was_viewport_at_bottom = Application.is_viewport_at_bottom()

    # replace if message with ID exists
    if @_selector().find("#chat_body .private_message[data-message-id=#{message_id}]").length
      @_selector().find("#chat_body .private_message[data-message-id=#{message_id}]").replaceWith message_html

    # add to bottom if ID is greater than that of most recent message
    # OR if this is the first message
    else if (message_id > parseInt(@_selector().find("#chat_body .private_message").last().attr("data-message-id"))) or (@_selector().find("#chat_body .private_message").length == 0)
      @_selector().find("#chat_body > .section.bottom").before message_html

    Application.jump_to_bottom_of_page() if was_viewport_at_bottom

  # returns the jquery selector for this conversation (or undefined if conversation is no longer open)
  _selector: ->
    $("div.private_conversation.show[data-conversation-id='#{@id}']")
