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
