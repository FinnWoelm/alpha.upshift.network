# run these actions after loading from cache (before fetching the fresh
# version)
$(document).on 'turbolinks:render', ->

  if $("body.c-private_conversations.a-show, body.c-private_messages").length

    # scroll to bottom of chat on page load
    Application.jump_to_bottom_of_page()
