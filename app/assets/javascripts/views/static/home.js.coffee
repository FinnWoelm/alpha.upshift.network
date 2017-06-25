# run these actions after fetching the fresh version from server
$(document).on 'turbolinks:load', ->

  if $("body.c-static.a-home").length

    # remove color scheme from navbar, force white text
    $("nav#main_navigation").removeClass("primary-color primary-color-text").addClass("white-text")
    # force white color of logo
    $("nav#main_navigation a.brand-logo img").removeClass("primary-color-text")
    # force white color on search
    $("#search").removeClass("primary-color-text").addClass("white-text")
