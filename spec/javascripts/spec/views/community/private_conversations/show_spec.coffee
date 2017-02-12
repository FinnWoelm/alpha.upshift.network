describe 'View: PrivateConversation#show', ->

  active_conversation =
  preview_for_active_conversation = null

  beforeEach ->
    $("body").addClass('c-private_conversations a-show')
    active_conversation = PrivateConversation.get_active_conversation()
    preview_for_active_conversation = active_conversation.get_preview()

  afterEach ->
    $("body").removeClass('c-private_conversations a-show')

  describe "on turbolinks:render", ->

    it "jumps to bottom of page", ->
      spyOn(Application, 'jump_to_bottom_of_page')
      $(document).trigger 'turbolinks:render'
      expect(Application.jump_to_bottom_of_page).toHaveBeenCalled()

    it "highlights the active conversation", ->
      spyOn(PrivateConversation, "get_active_conversation").and.
        returnValue(active_conversation)
      spyOn(active_conversation, "get_preview").and.
        returnValue(preview_for_active_conversation)
      spyOn(preview_for_active_conversation, "highlight")
      $(document).trigger 'turbolinks:render'
      expect(preview_for_active_conversation.highlight).toHaveBeenCalled()

  describe "on turbolinks:load", ->

    it "sets up chat body and compose message form", ->
      spyOn(PrivateConversation, "get_active_conversation").and.
        returnValue(active_conversation)
      spyOn(active_conversation, "set_up_chat_body_and_compose_message_form")
      $(document).trigger 'turbolinks:load'
      expect(active_conversation.set_up_chat_body_and_compose_message_form).
        toHaveBeenCalled()

    it "enables caching of previews", ->
      spyOn(PrivateConversationPreview, "enable_caching")
      $(document).trigger 'turbolinks:load'
      expect(PrivateConversationPreview.enable_caching).toHaveBeenCalled()

    describe "BackgroundJob: fetch new messages", ->

      id = callback = interval = null

      beforeEach ->
        spyOn(BackgroundJob, 'add')
        $(document).trigger 'turbolinks:load'
        id        = BackgroundJob.add.calls.argsFor(0)[0]
        callback  = BackgroundJob.add.calls.argsFor(0)[1]
        interval  = BackgroundJob.add.calls.argsFor(0)[2]

      it "creates with ID 'private-conversation-fetch-new-messages'", ->
        expect(id).toEqual 'private-conversation-fetch-new-messages'

      it "creates with interval 1000ms", ->
        expect(interval).toEqual 1000

      it "creates with callback fetch_new_messages()", ->
        spyOn(PrivateConversation, "get_active_conversation").and.
          returnValue(active_conversation)
        spyOn(active_conversation, 'fetch_new_messages')
        callback()
        expect(active_conversation.fetch_new_messages).toHaveBeenCalled()

    describe "BackgroundJob: fetch new conversation previews", ->

      id = callback = interval = null

      beforeEach ->
        spyOn(BackgroundJob, 'add')
        $(document).trigger 'turbolinks:load'
        id        = BackgroundJob.add.calls.argsFor(1)[0]
        callback  = BackgroundJob.add.calls.argsFor(1)[1]
        interval  = BackgroundJob.add.calls.argsFor(1)[2]

      it "creates with ID 'private-conversation-preview-fetch-new-previews'", ->
        expect(id).toEqual 'private-conversation-preview-fetch-new-previews'

      it "creates with interval 5000ms", ->
        expect(interval).toEqual 5000

      it "creates with callback fetch_new_previews()", ->
        spyOn(PrivateConversationPreview, 'fetch_new_previews')
        callback()
        expect(PrivateConversationPreview.fetch_new_previews).toHaveBeenCalled()
