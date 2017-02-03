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
