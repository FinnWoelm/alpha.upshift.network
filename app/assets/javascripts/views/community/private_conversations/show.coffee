# run these actions after loading from cache (before fetching the fresh
# version)
$(document).on 'turbolinks:render', ->

  if $("body.c-private_conversations.a-show, body.c-private_messages").length

    # scroll to bottom of chat on page load
    Application.jump_to_bottom_of_page()

# run these actions after fetching the fresh version from server
$(document).on 'turbolinks:load', ->

  if $("body.c-private_conversations.a-show, body.c-private_messages").length

    # set up compose message form
    PrivateConversation.get_active_conversation().
      set_up_chat_body_and_compose_message_form()

    # scroll to bottom of chat on page load
    Application.jump_to_bottom_of_page()

    # send messages using ctrl + enter
    $('form#new_private_message textarea#private_message_content').keydown (e) ->
      if e.keyCode == 13 && e.ctrlKey
        $(this).parents("form").first().find("button[type=submit]").click()
