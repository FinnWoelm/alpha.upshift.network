//= require jquery
//= require main

describe 'Main', ->

  # show notice if page is not cached
  describe "#show_notice()", ->

    afterAll ->
      $("div.toast").remove()

    describe "when page is cached", ->

      it 'does not add a toast', ->
        $("body").attr("data-is-cached", "true")
        show_notice("test", 5000)
        expect($("div.toast").length).toBe(0)

    describe "when page is fresh", ->

      it 'does add a toast', ->
        $("body").attr("data-is-cached", 0)
        show_notice("test", 5000)
        expect($("div.toast").length).toBe(1)
