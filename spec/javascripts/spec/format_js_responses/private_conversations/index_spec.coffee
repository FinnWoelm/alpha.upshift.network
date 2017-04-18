describe 'JS-Response: PrivateConversation#index', ->

  response = null

  beforeEach ->
    MagicLamp.load "private_conversations/side_navigation"
    response = MagicLamp.loadRaw "private_conversations/index_js"

  it "adds 5 previews as previous conversations", ->
    spyOn(PrivateConversationPreview, "add_previous_conversation").and.callThrough()
    eval(response)
    expect(PrivateConversationPreview.add_previous_conversation.calls.count()).toEqual 5

  it "adds previews in order of most recent conversations", ->
    eval(response)
    number_of_previews = $(".preview_conversation:eq(0)").length
    expect(
      ExactDate.parse(
        $(".preview_conversation:eq(#{number_of_previews-1})").attr("data-updated-at")
      ).to_f()
    ).toBeLessThan(
      ExactDate.parse(
        $(".preview_conversation:eq(#{number_of_previews-2})").attr("data-updated-at")
      ).to_f()
    )

    expect(
      ExactDate.parse(
        $(".preview_conversation:eq(#{number_of_previews-2})").attr("data-updated-at")
      ).to_f()
    ).toBeLessThan(
      ExactDate.parse(
        $(".preview_conversation:eq(#{number_of_previews-3})").attr("data-updated-at")
      ).to_f()
    )

    expect(
      ExactDate.parse(
        $(".preview_conversation:eq(#{number_of_previews-3})").attr("data-updated-at")
      ).to_f()
    ).toBeLessThan(
      ExactDate.parse(
        $(".preview_conversation:eq(#{number_of_previews-4})").attr("data-updated-at")
      ).to_f()
    )

  it "initializes new tooltips", ->
    spyOn(Application, 'init_new_tooltips')
    eval(response)
    expect(Application.init_new_tooltips).toHaveBeenCalled()

  it "initializes new dropdowns", ->
    spyOn(Application, 'init_new_dropdowns')
    eval(response)
    expect(Application.init_new_dropdowns).toHaveBeenCalled()
