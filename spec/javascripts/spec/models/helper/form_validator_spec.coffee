describe 'Model: FormValidator', ->

  form = null

  beforeEach ->
    MagicLamp.load("users/edit")
    form = new FormValidator "#edit_profile", "user"

  ## Instance: Public

  describe ".add_error", ->

    it "adds one error to the input field", ->
      form.add_error "name", "some error"
      expect($("#user_name").siblings("ul").children().length).toEqual 1

    it "shows the specified error", ->
      form.add_error "name", "some error"
      expect($("#user_name").siblings("ul").html()).toContain "some error"

    it "adds the error to the bottom of the parent container", ->
      form.add_error "name", "some error"
      expect($("#user_name").parent().children().last().hasClass("errors")).toBeTruthy()

    it "adds multiple errors", ->
      form.add_error "name", "some error 1"
      form.add_error "name", "some error 2"
      form.add_error "name", "some error 3"
      form.add_error "name", "some error 4"
      expect($("#user_name").siblings("ul").length).toEqual 1
      expect($("#user_name").siblings("ul").children().length).toEqual 4


  describe ".clear_errors", ->

    beforeEach ->
      form.add_error "name", "some error 1"
      form.add_error "bio", "some error 2"

    it "removes all error containers", ->
      form.clear_errors()
      expect($("#edit_profile ul.errors").length).toEqual 0
