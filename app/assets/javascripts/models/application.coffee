class @Application

  # Methods
  #
  #/ Static: Public
  #// is_viewport_at_bottom = is the viewport at the bottom of the screen?
  #// show_notice(notice, duration) = displays a toast for the given duration
  #//                                 (unless the site is loaded from cache)
  #/
  #/ Static: Private
  #// is_cached_page = is this page loaded from cache?

  @is_viewport_at_bottom: ->
    ($(window).scrollTop() >= $(document).height() - $(window).height())

  @show_notice: (notice, duration) ->
    Materialize.toast(notice, duration) unless @_is_cached_page()

  # Is user looking at a cached version of the page?
  @_is_cached_page = ->
    $("body").attr("data-is-cached") == "true"
