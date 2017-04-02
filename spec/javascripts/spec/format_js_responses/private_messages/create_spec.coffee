describe 'JS-Response: PrivateMessages#create', ->

  active_conversation =
  response = null

  beforeEach ->
    MagicLamp.load "private_conversations/show", "private_conversations/side_navigation"
    active_conversation = PrivateConversation.get_active_conversation()
    response = MagicLamp.loadRaw "private_messages/create"
    spyOn(window, 'PrivateConversation').and.returnValue(active_conversation)

  it "adds the messages", ->
    spyOn(active_conversation, "add_message_from_user_compose_form").and.callThrough()
    eval(response)
    expect(active_conversation.add_message_from_user_compose_form).toHaveBeenCalled()
    expect($(".private_message").length).toEqual 21

  it "adds the preview", ->
    spyOn(PrivateConversationPreview, "add").and.callThrough()
    eval(response)
    expect(PrivateConversationPreview.add).toHaveBeenCalled()
    expect($(".private_conversation_previews .preview_conversation").length).toEqual 6

  it "initializes new tooltips", ->
    spyOn(Application, 'init_new_tooltips')
    eval(response)
    expect(Application.init_new_tooltips).toHaveBeenCalled()
