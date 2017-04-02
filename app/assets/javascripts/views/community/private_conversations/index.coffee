# run these actions after fetching the fresh version from server
$(document).on 'turbolinks:load', ->

  if $("body.c-private_conversations.a-index").length

    # get latest previews from server
    if not $("div.infinity_scroll.fallback").length
      BackgroundJob.add(
        "private-conversation-preview-fetch-new-previews",
        -> PrivateConversationPreview.fetch_new_previews('asc', 'false'),
        5000
      )
