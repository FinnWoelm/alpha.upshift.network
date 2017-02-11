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


  describe "#_selector", ->

    describe "when conversation is active", ->

      it "returns the JQuery selector", ->
        conversation_id = $("div.private_conversation.show").attr("data-conversation-id")
        expect((new PrivateConversation(conversation_id))._selector().length).toEqual 1

    describe "when conversation is not active", ->

      it "returns object with length 0", ->
        some_random_id = "abc123"
        expect((new PrivateConversation(some_random_id))._selector().length).toEqual 0
