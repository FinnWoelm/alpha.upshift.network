# run these actions after fetching the fresh version from server
$(document).on 'turbolinks:load', ->

  # resize side nav to full height when DOM height changes
  if $("#desktop_side_navigation").length
    new ResizeSensor(
      $("body:not(.fullscreen)"), ->
        Application.resize_side_nav_to_full_height()
      )

  actions_on_resize = ->
    # resize side nav to document height
    Application.resize_side_nav_to_full_height()
    # resize search to full width of nav bar
    Application.resize_search_to_full_width()

  # execute actions on resize
  $( window ).resize -> actions_on_resize()

  # execute actions right now
  actions_on_resize()
