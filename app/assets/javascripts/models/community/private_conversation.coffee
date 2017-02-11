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
  #// set_up_chat_body_and_compose_message_form: Set max height on form and add
  #//                                            margin-bottom to chat_body.
  #//                                            Also handle resizing.
  #
  #/ Instance: Private
  #// add_messages: appends one or multiple messages to the bottom of the chat
  #//               (and moves viewport)
  #// determine_if_stick_to_bottom: add class 'stick_to_bottom' to body if user
  #//                               has scrolled to bottom
  #// selector: returns the jquery selector for this conversation
  #// set_max_height_for_compose_message_form: set css field max-height for
  #//                                          form to 1/2 of viewport

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


  # Set max height on form and add margin-bottom to chat_body. Also handle
  # resizing of window and form.
  set_up_chat_body_and_compose_message_form: ->

    # set max-height for compose message form
    @_set_max_height_for_compose_message_form()

    # if window is resized, let us reset max-height for form
    $( window ).resize ->
      PrivateConversation.get_active_conversation()._set_max_height_for_compose_message_form()

    # set margin-bottom on chat body
    @_selector().find("#chat_body").css 'margin-bottom', $("#compose_message").innerHeight()

    # add class 'stick_to_bottom' to body if user has scrolled to bottom
    @_determine_if_stick_to_bottom()

    # re-run this whenever the user scrolls
    $(window).scroll ->
      PrivateConversation.get_active_conversation()._determine_if_stick_to_bottom()

    # automatically update margin-bottom for chat body as compose message div
    # changes in height and scroll to bottom of viewport
    # Credits: ResizeSensor is the work of @MarcJSchmidt, learn more at
    # https://github.com/marcj/css-element-queries
    new ResizeSensor @_selector().find('#compose_message'), ->

      PrivateConversation.get_active_conversation()._selector().
        find("#chat_body").css(
          'margin-bottom', $("#compose_message").innerHeight()
        )

      Application.jump_to_bottom_of_page() if $("body").hasClass("stick_to_bottom")


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

  # add class 'stick_to_bottom' to body if user has scrolled to bottom
  _determine_if_stick_to_bottom: ->
     $("body").removeClass("stick_to_bottom")
     if Application.is_viewport_at_bottom()
       $("body").addClass("stick_to_bottom")

  # returns the jquery selector for this conversation (or undefined if conversation is no longer open)
  _selector: ->
    $("div.private_conversation.show[data-conversation-id='#{@id}']")

  # set css field max-height for form to 1/2 of viewport
  _set_max_height_for_compose_message_form: ->

    height_of_viewport = $(window).height()

    height_of_main_navigation = $("#main_navigation").innerHeight()
    height_of_chat_header = $("div.page_heading").innerHeight()

    remaining_vertical_space =
      height_of_viewport - height_of_main_navigation - height_of_chat_header

    # amount of space we are using around the textarea
    vertical_spacing_in_compose_message =
      @_selector().find("#compose_message").outerHeight() -
      @_selector().find("#compose_message .materialize-textarea").height()

    # the compose area gets max-height of half the window space
    @_selector().find("#compose_message .materialize-textarea").css(
      'max-height',
      remaining_vertical_space / 2 - vertical_spacing_in_compose_message
    )
