# run these actions after fetching the fresh version from server
$(document).on 'turbolinks:load', ->

  if $("body.c-private_conversations.a-new").length or $("body.c-private_conversations.a-create").length

    # cache the side navigation
    PrivateConversationPreview.enable_caching()

    # get latest previews from server
    BackgroundJob.add(
      "private-conversation-preview-fetch-new-previews",
      -> PrivateConversationPreview.fetch_new_previews(),
      5000
    )
