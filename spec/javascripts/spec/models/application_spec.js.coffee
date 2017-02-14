//= require jquery
//= require models/application

describe 'Application', ->

  describe "#is_viewport_at_bottom", ->

    beforeEach ->
      MagicLamp.load "static/home"
      $("#static_home").height $(window).height() * 3

    describe "when viewport is at bottom", ->

      beforeEach ->
        $(window).scrollTop $(document).height()

      it "returns true", ->
        expect(Application.is_viewport_at_bottom()).toBeTruthy()

    describe "when viewport is not at bottom", ->

      beforeEach ->
        $(window).scrollTop $(document).height() - $(window).height() - 1

      it "returns false", ->
        expect(Application.is_viewport_at_bottom()).toBeFalsy()


    describe "#resize_side_nav_to_full_height", ->

      beforeEach ->
        MagicLamp.load "static/home"
        # add main navigation with height 64px
        $(".magic-lamp").append("<div id='main_navigation'></div>")
        $("#main_navigation").height 64
        # add side navigation
        $(".magic-lamp").append("<div id='desktop_side_navigation' style='position:fixed;'></div>")

      describe "when document is longer than viewport", ->

        beforeEach ->
          $(".magic-lamp").height $(window).height() * 5

        it "sets side nav to extend over full document", ->
          expect($(document).height()).toBeGreaterThan $(window).height()
          Application.resize_side_nav_to_full_height()
          nav_height = $(document).height() - $("#main_navigation").height()
          expect($("#desktop_side_navigation").height()).toEqual nav_height

      describe "when document is shorter than viewport", ->

        beforeEach ->
          $("body").css('max-height', $(window).height() - 100)

        afterEach ->
          $("body").css('max-height', 'unset')

        it "sets side nav to fill viewport", ->
          expect($("body").height()).not.toBeGreaterThan $(window).height()
          Application.resize_side_nav_to_full_height()
          nav_height = $(window).height() - $("#main_navigation").height()
          expect($("#desktop_side_navigation").height()).toEqual nav_height

      describe "when layout is fullscreen", ->

        beforeEach ->
          $(".magic-lamp").height $(window).height() * 5
          $("body").addClass("fullscreen")

        it "limits sidenav to screen height and overflows vertically", ->
          Application.resize_side_nav_to_full_height()
          nav_height = $(window).height() - $("#main_navigation").height()
          expect($("#desktop_side_navigation").height()).toEqual nav_height


  describe "#show_notice", ->

    afterAll ->
      $("div.toast").remove()

    describe "when page is cached", ->

      it 'does not add a toast', ->
        $("body").attr("data-is-cached", "true")
        Application.show_notice("test", 5000)
        expect($("div.toast").length).toBe(0)

    describe "when page is fresh", ->

      it 'does add a toast', ->
        $("body").attr("data-is-cached", 0)
        Application.show_notice("test", 5000)
        expect($("div.toast").length).toBe(1)
