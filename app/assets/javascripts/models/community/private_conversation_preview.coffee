class @PrivateConversationPreview

  # Methods
  #
  #/ Static: Public
  #// add: adds a preview (and deletes existing ones with the same conversation
  #//      ID)
  #// enable_caching: adds data-turbolinks-permanent to the previews, so that
  #//                 they can persist when user navigates browser back
  #//
  #/ Instance: Public
  #// highlight: adds css class 'active' to the preview
  #
  #/ Instance: Private
  #// selector: returns the jquery selector for this conversation preview


  #########################
  # Public Static Methods #
  #########################

  constructor: (@id) ->
    @updated_at = if @_selector().length then ExactDate.parse @_selector().attr("data-updated-at") else new ExactDate(0)

  # adds a preview (or overwrites if it already exists)
  @add: (conversation_id, updated_at, html_of_preview, update_updated_at) ->

    # do nothing if a preview for this conversation already exists (with
    # updated_at greater than this one)
    return if (new PrivateConversationPreview conversation_id).updated_at.to_f() > ExactDate.parse(updated_at).to_f()

    # delete any existing preview with this ID
    $(".preview_conversation[data-conversation-id='#{conversation_id}']").remove()

    # insert at top
    $("div.private_conversation_previews").prepend html_of_preview

    # remove any and all conversation previews that exceed the limit of 10
    $("#desktop_side_navigation .preview_conversation").slice(10).remove()
    $("#mobile_navigation .preview_conversation").slice(10).remove()

    # highlight the active conversation
    PrivateConversation.get_active_conversation().get_preview().highlight()

    # update data-updated-at on sidenav
    if update_updated_at
      $("div.private_conversation_previews").
        attr("data-updated-at", updated_at)


  # makes previews of private conversations in side navigation
  # turbolinks-permanent, so that they remain in current state when navigating
  # to a prior site
  @enable_caching: ->
    $("#desktop_side_navigation .private_conversation_previews").
      attr("id", "private_conversation_previews_cached_desktop")
    $("#mobile_navigation .private_conversation_previews").
      attr("id", "private_conversation_previews_cached_mobile")

    $(".private_conversation_previews").attr("data-turbolinks-permanent", "true")


  ###########################
  # Public Instance Methods #
  ###########################

  highlight: ->
    $(".preview_conversation").removeClass("active")
    @_selector().addClass("active")

  ###########################!
  # Private Instance Methods #
  ############################

  _selector: ->
    $("div.private_conversation_previews .preview_conversation[data-conversation-id='#{@id}']")
