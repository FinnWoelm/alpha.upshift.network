describe 'View: User#show', ->

  beforeEach ->
    $("body").addClass('c-users a-edit')

  afterEach ->
    $("body").removeClass('c-users a-edit')

  describe "on turbolinks:load", ->

    it "initializes image uploads", ->
      spyOn(User, "initialize_image_upload")
      $(document).trigger 'turbolinks:load'
      expect(User.initialize_image_upload.calls.count()).toEqual(2)

    it "initializes color select", ->
      spyOn(User, "initialize_color_select")
      $(document).trigger 'turbolinks:load'
      expect(User.initialize_color_select).toHaveBeenCalled()
