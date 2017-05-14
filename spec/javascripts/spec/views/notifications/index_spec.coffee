# describe 'View: Notifications#index', ->
#
#   beforeEach ->
#     MagicLamp.load("notifications/index")
#     $("body").addClass('c-notifications a-index')
#
#   afterEach ->
#     $("body").removeClass('c-notifications a-index')
#
#   describe "on turbolinks:load", ->
#
#     beforeEach ->
#       $(document).trigger 'turbolinks:load'
#
#     describe "when user clicks on notification", ->
#
#       it "triggers click on 'mark seen'", ->
#         # spy on clicks
#         click = spyOn($.fn, 'click').and.callThrough()
#         notification_id = $("div.notification").first().attr("data-notification-id")
#
#         # remove the href attribute so that we don't navigate away from the page
#         $("div.notification[data-notification-id='#{notification_id}'] > a.hoverable").attr("href", "#")
#
#         # trigger the click
#         $("div.notification[data-notification-id='#{notification_id}'] > a.hoverable").trigger('click')
#
#         expect(click.calls.mostRecent().object[0].tagName.toLowerCase()).toEqual "button"
#         expect($(click.calls.mostRecent().object[0]).parents("li.mark_seen.action").length).toEqual 1
#         expect($(click.calls.mostRecent().object[0]).parents("div.notification").attr("data-notification-id")).toEqual notification_id
