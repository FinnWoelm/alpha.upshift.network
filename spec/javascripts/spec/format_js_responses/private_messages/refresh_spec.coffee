describe 'JS-Response: PrivateMessages#refresh', ->

  active_conversation =
  response = null

  active_conversation =
  response = null

  beforeEach ->
    MagicLamp.load "private_conversations/show"
    active_conversation = PrivateConversation.get_active_conversation()
    response = MagicLamp.loadRaw "private_messages/refresh"
    spyOn(window, 'PrivateConversation').and.returnValue(active_conversation)

  it "adds the messages", ->
    spyOn(active_conversation, "add_new_messages").and.callThrough()
    eval(response)
    expect(active_conversation.add_new_messages).toHaveBeenCalled()
    expect($(".private_message").length).toEqual 23

  it "updates the preview", ->
    spyOn(PrivateConversationPreview, 'add').and.callThrough()
    eval(response)
    expect(PrivateConversationPreview.add).toHaveBeenCalled()

  it "initializes new tooltips", ->
    spyOn(Application, 'init_new_tooltips')
    eval(response)
    expect(Application.init_new_tooltips).toHaveBeenCalled()
