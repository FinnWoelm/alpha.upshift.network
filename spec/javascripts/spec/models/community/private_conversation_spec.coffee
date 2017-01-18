describe 'Model: PrivateConversation', ->

  active_conversation =
  id_of_last_message = null

  beforeEach ->
    MagicLamp.load("private_conversations/show")
    active_conversation = PrivateConversation.get_active_conversation()
    id_of_last_message = parseInt(
      $("#chat_body div.private_message").last().attr("data-message-id")
    )

  ## Static: Public

  describe ".get_active_conversation", ->

    it "returns a private conversation object with the ID of current
      conversation", ->
      expect(PrivateConversation.get_active_conversation()).
        toEqual jasmine.any(PrivateConversation)
      expect(PrivateConversation.get_active_conversation().id).
        toEqual $("div.private_conversation.show").data("conversation-id")


  ## Instance: Public

  describe "#add_message_from_user_compose_form", ->

    message_id =
    message_html = null

    beforeEach ->
      message_id = id_of_last_message + 1
      message_html = "<div class='private_message' data-message-id='#{message_id}'>my private message 1234</div>"

    it "calls _add_message", ->
      spyOn(active_conversation, '_add_message')
      active_conversation.add_message_from_user_compose_form message_id, message_html
      expect(active_conversation._add_message).toHaveBeenCalledWith message_id, message_html

    it "marks the message as pushed", ->
      active_conversation.add_message_from_user_compose_form message_id, message_html
      expect($("#chat_body .private_message[data-message-id=#{message_id}]").hasClass('pushed')).toBeTruthy()

    it "clears the user compose form", ->
      $("#compose_message form .materialize-textarea").val("mystring")
      active_conversation.add_message_from_user_compose_form message_id, message_html
      expect($("#compose_message form .materialize-textarea").val()).toEqual ""


  describe "#add_new_messages", ->

    messages = null

    beforeEach ->
      messages = [
        [message_id = id_of_last_message+1, message_html = "<div class='private_message' data-message-id='#{id_of_last_message+1}'>some_content1</div>"],
        [message_id = id_of_last_message+2, message_html = "<div class='private_message' data-message-id='#{id_of_last_message+2}'>some_content2</div>"],
        [message_id = id_of_last_message+3, message_html = "<div class='private_message' data-message-id='#{id_of_last_message+3}'>some_content3</div>"],
      ]

    it "clears 'unfetched' messages", ->
      active_conversation.add_message_from_user_compose_form messages[0][0], messages[0][1]
      expect($("#chat_body .private_message.pushed").length).toEqual 1
      active_conversation.add_new_messages messages
      expect($("#chat_body .private_message.pushed").length).toEqual 0

    it "calls _add_message for each message", ->
      spyOn(active_conversation, '_add_message')
      active_conversation.add_new_messages messages
      expect(active_conversation._add_message).toHaveBeenCalledWith messages[0][0], messages[0][1]
      expect(active_conversation._add_message).toHaveBeenCalledWith messages[1][0], messages[1][1]
      expect(active_conversation._add_message).toHaveBeenCalledWith messages[2][0], messages[2][1]


  describe "#fetch_new_messages", ->

    beforeEach ->
      spyOn($, 'get')
      active_conversation.fetch_new_messages()

    it "makes an ajax:get call", ->
      expect($.get).toHaveBeenCalled()

    it "sends the ID of last fetched message", ->
      id_of_last_fetched_message =
        $("#chat_body div.private_message:not(.pushed)").last().attr("data-message-id")
      expect($.get.calls.argsFor(0)[0].url).toContain id_of_last_fetched_message

    it "sends the ID of the conversation", ->
      expect($.get.calls.argsFor(0)[0].url).toContain active_conversation.id

    it "calls the refresh action", ->
      expect($.get.calls.argsFor(0)[0].url).toContain "refresh"

    it "requests content type: JS", ->
      expect($.get.calls.argsFor(0)[0].url).toContain ".js?"


  describe "#get_preview", ->

    it "returns a PrivateConversationPreview object with the ID of current
      conversation", ->
      preview = PrivateConversation.get_active_conversation().get_preview()
      expect(preview).toEqual jasmine.any(PrivateConversationPreview)
      expect(preview.id).
        toEqual $("div.private_conversation.show").attr("data-conversation-id")


  describe "#mark_deleted", ->

    it "disables the submit button", ->
      PrivateConversation.get_active_conversation().mark_deleted("conversation was deleted")
      expect($("#compose_message form button").hasClass("disabled")).toBeTruthy()

    it "marks the textarea readonly", ->
      PrivateConversation.get_active_conversation().mark_deleted("conversation was deleted")
      expect($("#compose_message form textarea").prop("readonly")).toBeDefined()

    it "adds the message to the chat body", ->
      PrivateConversation.get_active_conversation().mark_deleted("conversation was deleted")
      expect($("#chat_body").html()).toContain("conversation was deleted")


  describe "#set_up_chat_body_and_compose_message_form", ->

    height_of_viewport = $(window).height()
    active_conversation = null

    beforeEach ->
      active_conversation = PrivateConversation.get_active_conversation()
      active_conversation.set_up_chat_body_and_compose_message_form()

    it "calls ._set_max_height_for_compose_message_form", ->
      spyOn(active_conversation, '_set_max_height_for_compose_message_form')
      active_conversation.set_up_chat_body_and_compose_message_form()
      expect(active_conversation._set_max_height_for_compose_message_form).
        toHaveBeenCalled()

    it "calls ._determine_if_stick_to_bottom", ->
      spyOn(active_conversation, '_determine_if_stick_to_bottom')
      active_conversation.set_up_chat_body_and_compose_message_form()
      expect(active_conversation._determine_if_stick_to_bottom).
        toHaveBeenCalled()

    it "adds margin-bottom to #chat_body equal to form height", ->
      margin_bottom_of_chat_body = parseInt(
        $("#chat_body").css("margin-bottom")
      )
      message_form_height = $("#compose_message").innerHeight()
      expect(margin_bottom_of_chat_body).toEqual message_form_height

    describe "when window is resized", ->

      beforeEach ->
        spyOn(PrivateConversation, 'get_active_conversation').and.returnValue(
          active_conversation
        )
        spyOn(active_conversation, '_set_max_height_for_compose_message_form')
        $(window).trigger 'resize'

      it "calls ._set_max_height_for_compose_message_form", ->
        expect(active_conversation._set_max_height_for_compose_message_form).
          toHaveBeenCalled()

    describe "when window is scrolled", ->

      beforeEach ->
        spyOn(PrivateConversation, 'get_active_conversation').and.returnValue(
          active_conversation
        )
        spyOn(active_conversation, '_determine_if_stick_to_bottom')
        $(window).trigger 'scroll'

      it "calls ._determine_if_stick_to_bottom", ->
        expect(active_conversation._determine_if_stick_to_bottom).
          toHaveBeenCalled()

    describe "ResizeSensor", ->

      resize_sensor_function =
      resize_sensor_element = null

      beforeEach ->
        spyOn(window, 'ResizeSensor')
        active_conversation.set_up_chat_body_and_compose_message_form()
        resize_sensor_element = window.ResizeSensor.calls.argsFor(0)[0]
        resize_sensor_function = window.ResizeSensor.calls.argsFor(0)[1]

      it "creates a ResizeSensor on #compose_message", ->
        expect(window.ResizeSensor).toHaveBeenCalled()
        expect(resize_sensor_element.attr('id')).toEqual "compose_message"

      describe "when ResizeSensor is triggered", ->

        it "adjusts margin-bottom", ->
          total_height_of_form = $("#compose_message").innerHeight()
          $("#chat_body").css('margin-bottom', total_height_of_form - 5)
          resize_sensor_function.call()
          expect(parseInt($("#chat_body").css('margin-bottom'))).
            toEqual total_height_of_form

        describe "when body has class 'stick_to_bottom'", ->

          beforeEach ->
            $("body").addClass("stick_to_bottom")
            spyOn(Application, 'jump_to_bottom_of_page')

          it "jumps to bottom of page", ->
            resize_sensor_function.call()
            expect(Application.jump_to_bottom_of_page).toHaveBeenCalled()


  ## Instance: Private

  describe "#_add_message", ->

    message_id =
    message_html = null

    beforeEach ->
      message_id = id_of_last_message + 1
      message_html = "<div class='private_message' data-message-id='#{message_id}'>my private message 1234</div>"

    describe "when a message with given message ID already exists", ->

      it "overrides the old message", ->
        message_html = "<div class='private_message' data-message-id='#{message_id}'>this text should not exist</div>"
        active_conversation._add_message message_id, message_html

        message_html = "<div class='private_message' data-message-id='#{message_id}'>this is the new text</div>"
        active_conversation._add_message message_id, message_html

        expect($("#chat_body .private_message[data-message-id=#{message_id}]").html()).not.toContain "this text should not exist"
        expect($("#chat_body .private_message[data-message-id=#{message_id}]").html()).toContain "this is the new text"

    describe "when no messages exist yet", ->

      beforeEach ->
        $("#chat_body .private_message").remove()

      it "appends the message to the bottom of the chat", ->
        active_conversation._add_message message_id, message_html
        expect($("#chat_body .private_message").length).toEqual 1
        expect($("#chat_body .private_message").last().html()).toContain "my private message 1234"

    describe "when the ID is greater than the ID of the most recent message", ->

      it "appends the message to the bottom of the chat", ->
        count = $("#chat_body .private_message").length
        active_conversation._add_message message_id, message_html
        expect($("#chat_body .private_message").length).toEqual count+1
        expect($("#chat_body .private_message").last().html()).toContain "my private message 1234"


    describe "when user has scrolled to bottom of chat", ->

      beforeEach ->
        $(window).scrollTop($(document).height())

      it "jumps to the bottom of the page", ->
        spyOn(Application, 'jump_to_bottom_of_page')
        active_conversation._add_message message_id, message_html, false
        expect(Application.jump_to_bottom_of_page).toHaveBeenCalled()

    describe "when user has not scrolled to bottom of chat", ->

      beforeEach ->
        $(window).scrollTop(50)

      it "does not jump to the bottom of the pages", ->
        spyOn(Application, 'jump_to_bottom_of_page')
        active_conversation._add_message message_id, message_html, false
        expect(Application.jump_to_bottom_of_page).not.toHaveBeenCalled()


  describe "#_determine_if_stick_to_bottom", ->

    beforeEach ->
      $(document).height($(window).height() * 5)

    describe "if user has scrolled to bottom", ->

      beforeEach ->
        spyOn(Application, 'is_viewport_at_bottom').and.returnValue(true)

      it "body has class 'stick_to_bottom'", ->
        PrivateConversation.get_active_conversation().
          _determine_if_stick_to_bottom()
        expect($("body").hasClass("stick_to_bottom")).toBeTruthy()

    describe "if user has not scrolled to bottom", ->

      beforeEach ->
        spyOn(Application, 'is_viewport_at_bottom').and.returnValue(false)

      it "body does not have class 'stick_to_bottom'", ->
        PrivateConversation.get_active_conversation().
          _determine_if_stick_to_bottom()
        expect($("body").hasClass("stick_to_bottom")).toBeFalsy()


  describe "#_selector", ->

    describe "when conversation is active", ->

      it "returns the JQuery selector", ->
        conversation_id = $("div.private_conversation.show").attr("data-conversation-id")
        expect((new PrivateConversation(conversation_id))._selector().length).toEqual 1

    describe "when conversation is not active", ->

      it "returns object with length 0", ->
        some_random_id = "abc123"
        expect((new PrivateConversation(some_random_id))._selector().length).toEqual 0


  describe "#_set_max_height_for_compose_message_form", ->

    height_of_viewport = $(window).height()

    beforeEach ->
      PrivateConversation.get_active_conversation().
        _set_max_height_for_compose_message_form()

    it "sets max-height of compose message form to half-height of viewport", ->
      max_height_of_form = parseInt(
        $("#compose_message .materialize-textarea").css("max-height")
      )
      vertical_spacing_around_form = parseInt(
        $("#compose_message").outerHeight() -
        $("#compose_message .materialize-textarea").height()
      )
      remaining_vertical_space =
        height_of_viewport -
        $("#main_navigation").innerHeight() -
        $("div.page_heading").innerHeight()
      expect(max_height_of_form).
        toEqual remaining_vertical_space / 2 - vertical_spacing_around_form
