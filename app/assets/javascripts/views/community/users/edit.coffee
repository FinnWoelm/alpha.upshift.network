# run these actions after fetching the fresh version from server
$(document).on 'turbolinks:load', ->

  if $("body.c-users.a-edit").length

    # initialize file input for profile banner
    User.initialize_image_upload $("form#edit_profile div.profile_banner")

    # initialize file input for profile picture
    User.initialize_image_upload $("form#edit_profile div.profile_picture")

    # initialize color selects
    User.initialize_color_select()
