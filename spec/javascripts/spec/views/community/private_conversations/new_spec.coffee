describe 'View: PrivateConversation#new', ->

  beforeEach ->
    $("body").addClass('c-private_conversations a-new')

  afterEach ->
    $("body").removeClass('c-private_conversations a-new')

  describe "on turbolinks:load", ->

    it "enables caching of previews", ->
      spyOn(PrivateConversationPreview, "enable_caching")
      $(document).trigger 'turbolinks:load'
      expect(PrivateConversationPreview.enable_caching).toHaveBeenCalled()

    describe "BackgroundJob: fetch new conversation previews", ->

      id = callback = interval = null

      beforeEach ->
        spyOn(BackgroundJob, 'add')
        $(document).trigger 'turbolinks:load'
        id        = BackgroundJob.add.calls.argsFor(0)[0]
        callback  = BackgroundJob.add.calls.argsFor(0)[1]
        interval  = BackgroundJob.add.calls.argsFor(0)[2]

      it "creates with ID 'private-conversation-preview-fetch-new-previews'", ->
        expect(id).toEqual 'private-conversation-preview-fetch-new-previews'

      it "creates with interval 5000ms", ->
        expect(interval).toEqual 5000

      it "creates with callback fetch_new_previews()", ->
        spyOn(PrivateConversationPreview, 'fetch_new_previews')
        callback()
        expect(PrivateConversationPreview.fetch_new_previews).toHaveBeenCalled()
