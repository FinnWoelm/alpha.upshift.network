describe 'Model: User', ->

  active_conversation =
  id_of_last_message = null

  beforeEach ->
    MagicLamp.load("users/edit")

  describe "initialize_color_select", ->

    beforeEach ->
      $("div.base_color select").val("red")
      $("body").addClass("primary-red primary-darken-2")
      $('select').material_select();
      User.initialize_color_select()

    it "triggers a value change to initialize shade selection", ->
      $("div.shade_color ul.select-dropdown li img").
        removeClass("red").addClass("purple")
      User.initialize_color_select()
      $("div.shade_color ul.select-dropdown li img").each ->
        expect($(@).hasClass("red")).toEqual true
        expect($(@).hasClass("purple")).toEqual false

    describe "when shade changes", ->

      it "updates the page's color scheme", ->
        $("div.shade_color select").val("accent-3")
        $("div.shade_color select").trigger('change')
        expect($("body").hasClass("primary-accent-3")).toEqual true
        expect($("body").hasClass("primary-darken-2")).toEqual false

    describe "when base color changes", ->

      beforeEach ->
        $("div.base_color select").val("pink")
        $("div.base_color select").trigger('change')

      it "updates the classes of shade colors", ->
        $("div.shade_color ul.select-dropdown li").each ->
          expect($(@).find("img").hasClass("pink")).toEqual true
          expect($(@).find("img").hasClass("red")).toEqual false

      it "updates the page's color scheme", ->
        expect($("body").hasClass("primary-pink")).toEqual true
        expect($("body").hasClass("primary-red")).toEqual false

      describe "when color's shades are limited", ->

        beforeEach ->
          $("div.base_color select").val("black")
          $("div.base_color select").trigger('change')

        it "disables unavailable options", ->
          expect(
            $("div.shade_color ul.select-dropdown li:not(.disabled)").length
          ).toEqual 1

        describe "when unavailable option is selected", ->

          it "selects basic", ->
            expect($("div.shade_color select").val()).toEqual "basic"



  describe "initialize_image_upload", ->

    container = null

    beforeEach ->
      container = $("form#edit_profile div.profile_banner")

    describe "when container has non-default image", ->

      beforeEach ->
        $(container).removeClass("default")
        spyOn(User, "enable_file_removal")
        User.initialize_image_upload $(container)

      it "enables file removal", ->
        expect(User.enable_file_removal).toHaveBeenCalled()

    describe "when upload button is clicked", ->

      beforeEach ->
        User.initialize_image_upload $(container)

      it "reads the image", ->
        spyOn(User, "read_image")
        $(container).find("input[type='file']").trigger('change')
        expect(User.read_image).toHaveBeenCalled()

      it "enables file loading", ->
        spyOn(User, "enable_file_loading")
        $(container).find("input[type='file']").trigger('change')
        expect(User.enable_file_loading).toHaveBeenCalled()

      it "sets .delete_image to false", ->
        $(container).find("input[type='file']").trigger('change')
        expect($("div.profile_banner .delete_picture").val()).toEqual "false"

      describe "read_image:callback", ->

        callback = null
        event = {target: {result: "some image"}}

        beforeEach ->
          spyOn(User, "read_image")
          $(container).find("input").trigger('change')
          callback = User.read_image.calls.argsFor(0)[1]

        it "enables file removal", ->
          spyOn(User, "enable_file_removal")
          callback(event)
          expect(User.enable_file_removal).toHaveBeenCalled()

        it "sets the image for the container", ->
          spyOn(User, "set_picture")
          callback(event)
          expect(User.set_picture).toHaveBeenCalledWith jasmine.anything(), event.target.result

    describe "when remove button is clicked", ->

      beforeEach ->
        User.initialize_image_upload $(container)
        $("div.profile_banner .remove").click()

      it "sets .delete_image to true", ->
        expect($("div.profile_banner .delete_picture").val()).toEqual "true"

      it "clears the file input field", ->
        # how can we even test this? Can we emulate selecting a file?
        expect($("div.profile_banner input[type='file']")[0].files.length).toEqual 0


  describe ".enable_file_removal", ->

    beforeEach ->
      User.enable_file_removal($("div.profile_picture"))

    it "shows the remove button", ->
      expect($("div.profile_picture .remove").hasClass("hide")).toEqual false

    it "hides the upload button", ->
      expect($("div.profile_picture .upload").hasClass("hide")).toEqual true

    it "hides the loading button", ->
      expect($("div.profile_picture .loading").hasClass("hide")).toEqual true

  describe ".enable_file_upload", ->

    beforeEach ->
      User.enable_file_upload($("div.profile_picture"))

    it "shows the upload button", ->
      expect($("div.profile_picture .upload").hasClass("hide")).toEqual false

    it "hides the remove button", ->
      expect($("div.profile_picture .remove").hasClass("hide")).toEqual true

    it "hides the loading button", ->
      expect($("div.profile_picture .loading").hasClass("hide")).toEqual true

  describe ".enable_file_loading", ->

    beforeEach ->
      User.enable_file_loading($("div.profile_picture"))

    it "shows the loading button", ->
      expect($("div.profile_picture .loading").hasClass("hide")).toEqual false

    it "hides the remove button", ->
      expect($("div.profile_picture .remove").hasClass("hide")).toEqual true

    it "hides the upload button", ->
      expect($("div.profile_picture .upload").hasClass("hide")).toEqual true

  describe ".set_picture", ->

    it "sets the container's background image", ->
      User.set_picture("div.profile_banner", "some_url")
      expect($("div.profile_banner").css("backgroundImage")).toContain "url("
      expect($("div.profile_banner").css("backgroundImage")).toContain "some_url"
