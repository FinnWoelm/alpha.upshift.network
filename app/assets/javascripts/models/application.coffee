class @Application

  # Methods
  #
  #/ Static: Public
  #// is_viewport_at_bottom = is the viewport at the bottom of the screen?
  #// resize_side_nav_to_full_height = resizes the side navigation to height
  #//                                  of viewport or document (whichever is
  #//                                  bigger). Exception: Fullscreen pages
  #//                                  always have side nav at height of
  #//                                  viewport.
  #// show_notice(notice, duration) = displays a toast for the given duration
  #//                                 (unless the site is loaded from cache)
  #/
  #/ Static: Private
  #// is_cached_page = is this page loaded from cache?

  @is_viewport_at_bottom: ->
    ($(window).scrollTop() >= $(document).height() - $(window).height())


  @resize_side_nav_to_full_height: ->

    # reset height of side_nav
    $("#desktop_side_navigation").css("height", "unset")

    # get the html height
    height_of_body = $("body").height()

    # get the viewport height
    height_of_viewport = $(window).height()

    # get the height of top navigation
    height_of_main_navigation = $("#main_navigation").height()

    # are we on a fullscreen page?
    fullscreen = $("body").hasClass("fullscreen")

    # if we are on a fullscreen page, then html height should be height of
    # viewport
    height_of_body = height_of_viewport if fullscreen

    # set side nav to whichever height is greater
    $("#desktop_side_navigation").height(
      Math.max(height_of_body, height_of_viewport) - height_of_main_navigation
    )


  @show_notice: (notice, duration) ->
    Materialize.toast(notice, duration) unless @_is_cached_page()

  # Is user looking at a cached version of the page?
  @_is_cached_page = ->
    $("body").attr("data-is-cached") == "true"
