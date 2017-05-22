class @Application

  # Methods
  #
  #/ Static: Public
  #// init_new_tooltips = Initializes new tooltips on the page
  #// init_new_dropdowns = Initializes new (and unfortunately old) dropdowns
  #//                      on the page
  #// is_viewport_at_bottom = is the viewport at the bottom of the screen?
  #// jump_to_bottom_of_page = moves viewport to bottom of the site
  #// resize_search_to_full_width = sets search bar to full available width
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

  @init_new_tooltips: ->
    $('.tooltipped').each ->
      if $(@).attr("data-tooltip-id") == undefined
        $(@).tooltip();

  @init_new_dropdowns: ->
    $('.dropdown-button').dropdown();

  @is_viewport_at_bottom: ->
    ($(window).scrollTop() >= $(document).height() - $(window).height())


  @jump_to_bottom_of_page = ->
    $('html, body').scrollTop( $(document).height() )


  @resize_search_to_full_width: ->

    return unless $("#search").length

    # prevent search from interfering
    #$("#search").width(0)

    # set the new width
    $("#search").width(
      $("nav#main_navigation .nav-wrapper > .col.s12").width() - # width of nav
      $("nav#main_navigation .brand-logo").outerWidth() - # logo
      ($("nav#main_navigation ul").outerWidth() - $("#search").width()) # nav bar links
    )


  @resize_side_nav_to_full_height: ->

    return unless $("#desktop_side_navigation").length

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


  @show_notice: (notice, duration = 5000) ->
    Materialize.toast(notice, duration) unless @_is_cached_page()

  # Is user looking at a cached version of the page?
  @_is_cached_page = ->
    $("body").attr("data-is-cached") == "true"
