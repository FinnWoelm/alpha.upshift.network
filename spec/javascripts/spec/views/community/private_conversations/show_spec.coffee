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
