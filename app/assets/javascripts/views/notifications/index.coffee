# run these actions after fetching the fresh version from server
$(document).on 'turbolinks:load', ->

  if $("body.c-notifications.a-index").length

    # when user opens notification, mark it as seen
    $("div.notification.unseen > a.hoverable").click ->

      $(@).parent().find(".administrative-actions li.mark_seen.action button").click()
