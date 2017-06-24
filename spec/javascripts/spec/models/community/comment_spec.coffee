describe 'Model: Comment', ->

  beforeEach ->
    MagicLamp.load("users/show")

  describe "initialize_new_comment_form", ->

    new_comment_form_wrapper = null

    beforeEach ->
      new_comment_form_wrapper =
        $(".comment.form-wrapper").first()
      Comment.initialize_new_forms()

    it "hides form", ->
      expect(
        new_comment_form_wrapper.children(".content.form").is(":visible")
      ).toBe false

    it "shows toggle", ->
      expect(
        new_comment_form_wrapper.children(".content.toggle-form").is(":visible")
      ).toBe true

    it "marks the form wrapper as initialized", ->
      expect(new_comment_form_wrapper.hasClass("initialized")).toBe true

    describe "on click", ->

      beforeEach ->
        jQuery.fx.off = true
        new_comment_form_wrapper.click()

      afterEach ->
        jQuery.fx.off = false

      it "shows form", ->
        expect(
          new_comment_form_wrapper.children(".content.form").is(":visible")
        ).toBe true

      it "hides toggle", ->
        expect(
          new_comment_form_wrapper.children(".content.toggle-form").is(":visible")
        ).toBe false

      it "cannot be clicked again", ->
          spyOn($.fn, "slideUp")
          spyOn($.fn, "slideDown")
          new_comment_form_wrapper.click()
          expect($.fn.slideUp).not.toHaveBeenCalled()
          expect($.fn.slideDown).not.toHaveBeenCalled()
