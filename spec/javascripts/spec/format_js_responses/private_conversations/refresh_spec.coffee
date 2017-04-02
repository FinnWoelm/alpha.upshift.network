describe 'JS-Response: PrivateConversation#refresh', ->

  response = null

  beforeEach ->
    MagicLamp.load "private_conversations/side_navigation"
    response = MagicLamp.loadRaw "private_conversations/refresh"

  it "adds 5 previews", ->
    spyOn(PrivateConversationPreview, "add").and.callThrough()
    eval(response)
    expect(PrivateConversationPreview.add.calls.count()).toEqual 5

  it "adds previews in order of most recent conversations", ->
    eval(response)
    expect(
      ExactDate.parse(
        $(".preview_conversation:eq(0)").attr("data-updated-at")
      ).to_f()
    ).toBeGreaterThan(
      ExactDate.parse(
        $(".preview_conversation:eq(1)").attr("data-updated-at")
      ).to_f()
    )

    expect(
      ExactDate.parse(
        $(".preview_conversation:eq(1)").attr("data-updated-at")
      ).to_f()
    ).toBeGreaterThan(
      ExactDate.parse(
        $(".preview_conversation:eq(2)").attr("data-updated-at")
      ).to_f()
    )

    expect(
      ExactDate.parse(
        $(".preview_conversation:eq(2)").attr("data-updated-at")
      ).to_f()
    ).toBeGreaterThan(
      ExactDate.parse(
        $(".preview_conversation:eq(3)").attr("data-updated-at")
      ).to_f()
    )
