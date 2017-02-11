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
