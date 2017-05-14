class @Notification

  # Methods
  #
  #/ Instance: Public
  #// mark_seen: marks the notification as seen
  #
  #/ Instance: Private
  #// selector: returns the jquery selector for this notification

  #########################
  # Static Public Methods #
  #########################

  constructor: (@id) ->

  ###########################
  # Public Instance Methods #
  ###########################

  # marks the notification as seen
  mark_seen: ->

    # mark notification as seen
    @_selector().removeClass("unseen").addClass("seen")

    # disable mark seen option in administrative-actions
    @_selector().find(".administrative-actions li.mark_seen.action").
      addClass("disabled")

  ############################
  # Private Instance Methods #
  ############################

  # returns the jquery selector for this notification (or undefined if
  # notification does not exist)
  _selector: ->
    $("div.notification[data-notification-id='#{@id}']")
