describe 'Model: PrivateConversationPreview', ->

  preview = null

  beforeEach ->
    MagicLamp.load("private_conversations/side_navigation")
    preview = new PrivateConversationPreview $(".preview_conversation").eq(0).attr("data-conversation-id")

  ## Static: Public

  describe ".add", ->

    conversation_id =
    updated_at =
    html_of_preview = null

    beforeEach ->
      conversation_id = "the-conversation-id-2235"
      updated_at = ExactDate.parse(
          $("div.private_conversation_previews").attr("data-updated-at")
        ).add(ExactDate.HOUR)
      html_of_preview = "<div class='preview_conversation' data-conversation-id='#{conversation_id}'>some preview content</div>"

    it "adds preview to the top", ->
      PrivateConversationPreview.add conversation_id, updated_at.to_s(), html_of_preview, false
      expect($(".preview_conversation").eq(0).attr("data-conversation-id")).toEqual "the-conversation-id-2235"
      expect($(".preview_conversation:eq(0)").html()).toEqual "some preview content"

    it "removes any but the most recent 10 previews", ->
      # wrap side nav in desktop and mobile side nav wrappers
      $(".magic-lamp").append("<div id='desktop_side_navigation' style='position:fixed;'></div>")
      $(".magic-lamp").append("<div id='mobile_navigation'></div>")
      $("#desktop_side_navigation").append $("div.private_conversation_previews")
      $("#mobile_navigation").append $("div.private_conversation_previews").clone()

      for n in [0..19]
        conversation_id = "some-new-id#{n}"
        PrivateConversationPreview.add conversation_id, updated_at.to_s(), html_of_preview, false
      expect($("#desktop_side_navigation .preview_conversation").length).toEqual 10
      expect($("#mobile_navigation .preview_conversation").length).toEqual 10

    it "re-highlights the active conversation", ->
      preview = PrivateConversation.get_active_conversation().get_preview()
      spyOn(preview, "highlight")
      PrivateConversationPreview.add conversation_id, updated_at.to_s(), html_of_preview, false
      expect(preview.highlight).toHaveBeenCalled

    describe "when update_last_fetched is true", ->

      it "updates data-updated-at on sidenav", ->
        PrivateConversationPreview.add conversation_id, updated_at.to_s(), html_of_preview, true
        expect(
          $("div.private_conversation_previews").
          attr("data-updated-at")
        ).toEqual "#{updated_at.to_s()}"


    describe "when preview for the conversation ID already exists", ->

      describe "when updated_at of existing preview is less or equally recent than updated_at of new one", ->

        beforeEach ->
          PrivateConversationPreview.add conversation_id, updated_at.to_s(), "<div class='preview_conversation' data-conversation-id='#{conversation_id}' data-updated-at='#{updated_at.to_s()}'>OLD CONTENT</div>", false

        it "deletes the existing content", ->
          expect($(".preview_conversation[data-conversation-id='#{conversation_id}']").length).toEqual 1
          PrivateConversationPreview.add conversation_id, updated_at.to_s(), "<div class='preview_conversation' data-conversation-id='#{conversation_id}' data-updated-at='#{updated_at.to_s()}'>NEW CONTENT</div>", false
          expect($(".preview_conversation[data-conversation-id='#{conversation_id}']").length).toEqual 1
          expect($(".preview_conversation:eq(0)").html()).toEqual "NEW CONTENT"

      describe "when updated_at of existing preview is more_recent than updated_at of new one", ->

        beforeEach ->
          PrivateConversationPreview.add conversation_id, updated_at.add(ExactDate.MICROSECOND).to_s(), "<div class='preview_conversation' data-conversation-id='#{conversation_id}' data-updated-at='#{updated_at.add(ExactDate.MICROSECOND).to_s()}'>OLD CONTENT</div>", false

        it "does not delete the existing preview (it does nothing)", ->
          expect($(".preview_conversation[data-conversation-id='#{conversation_id}']").length).toEqual 1
          PrivateConversationPreview.add conversation_id, updated_at.to_s(), "<div class='preview_conversation' data-conversation-id='#{conversation_id}' data-updated-at='#{updated_at.to_s()}'>NEW CONTENT</div>", false
          expect($(".preview_conversation[data-conversation-id='#{conversation_id}']").length).toEqual 1
          expect($(".preview_conversation:eq(0)").html()).toEqual "OLD CONTENT"


  ## Instance: Public

  describe "#highlight", ->

    it "removes all existing highlights", ->
      $(".preview_conversation").addClass("active")
      preview.highlight()
      expect($(".preview_conversation.active").length).toEqual 1

    it "adds css class 'active' to the preview", ->
      expect($(".preview_conversation[data-conversation-id='#{preview.id}']").hasClass("active")).toBeFalsy()
      preview.highlight()
      expect($(".preview_conversation[data-conversation-id='#{preview.id}']").hasClass("active")).toBeTruthy()


  ## Instance: Private

  describe "#_selector", ->

    describe "when preview is showing", ->

      it "returns the JQuery selector", ->
        conversation_id = $(".preview_conversation").eq(0).attr("data-conversation-id")
        expect((new PrivateConversationPreview(conversation_id))._selector().length).toEqual 1

    describe "when preview is not showing", ->

      it "returns object with length 0", ->
        some_random_id = "abc123"
        expect((new PrivateConversationPreview(some_random_id))._selector().length).toEqual 0
