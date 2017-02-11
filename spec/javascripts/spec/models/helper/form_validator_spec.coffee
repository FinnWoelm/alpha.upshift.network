describe 'Model: FormValidator', ->

  form = null

  beforeEach ->
    MagicLamp.load("registrations/new")
    form = new FormValidator "#new_user", "user"

  ## Instance: Public

  describe ".add_error", ->

    it "adds one error to the input field", ->
      form.add_error "username", "some error"
      expect($("#user_username").siblings("ul").children().length).toEqual 1

    it "shows the specified error", ->
      form.add_error "username", "some error"
      expect($("#user_username").siblings("ul").html()).toContain "some error"

    it "adds the error to the bottom of the parent container", ->
      form.add_error "username", "some error"
      expect($("#user_username").parent().children().last().hasClass("errors")).toBeTruthy()

    it "adds multiple errors", ->
      form.add_error "username", "some error 1"
      form.add_error "username", "some error 2"
      form.add_error "username", "some error 3"
      form.add_error "username", "some error 4"
      expect($("#user_username").siblings("ul").length).toEqual 1
      expect($("#user_username").siblings("ul").children().length).toEqual 4


  describe ".clear_errors", ->

    beforeEach ->
      form.add_error "username", "some error 1"
      form.add_error "name", "some error 2"
      form.add_error "email", "some error 3"

    it "removes all error containers", ->
      form.clear_errors()
      expect($("#new_user ul.errors").length).toEqual 0
