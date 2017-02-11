describe 'View: PrivateConversation#show', ->

  beforeEach ->
    $("body").addClass('c-private_conversations a-show')

  afterEach ->
    $("body").removeClass('c-private_conversations a-show')

  describe "on turbolinks:render", ->

    it "jumps to bottom of page", ->
      spyOn(Application, 'jump_to_bottom_of_page')
      $(document).trigger 'turbolinks:render'
      expect(Application.jump_to_bottom_of_page).toHaveBeenCalled()

  describe "on turbolinks:load", ->

    it "sets up chat body and compose message form", ->
      active_conversation = PrivateConversation.get_active_conversation()
      spyOn(PrivateConversation, "get_active_conversation").and.
        returnValue(active_conversation)
      spyOn(active_conversation, "set_up_chat_body_and_compose_message_form")
      $(document).trigger 'turbolinks:load'
      expect(active_conversation.set_up_chat_body_and_compose_message_form).
        toHaveBeenCalled()
