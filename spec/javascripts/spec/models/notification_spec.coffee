describe 'Model: Notification', ->

  active_conversation =
  id_of_last_message = null

  beforeEach ->
    MagicLamp.load("notifications/index")

  describe "#mark_seen", ->

    notification_id =
    notification = null

    beforeEach ->
      notification_id = $("div.notification").first().attr("data-notification-id")
      notification = new Notification(notification_id)
      notification.mark_seen()

    it "marks the notification as seen", ->
      expect($("div.notification[data-notification-id='#{notification_id}']").hasClass("seen")).toEqual true
      expect($("div.notification[data-notification-id='#{notification_id}']").hasClass("unseen")).toEqual false
      expect($("div.notification.seen").length).toEqual 1

    it "disables the 'mark seen' option in the dropdown", ->
      expect($("div.notification[data-notification-id='#{notification_id}'] .administrative-actions li.mark_seen.action").hasClass("disabled")).toEqual true


  describe "#_selector", ->

    describe "when notification exists", ->

      it "returns the JQuery selector", ->
        notification_id = $("div.notification").first().attr("data-notification-id")
        expect((new Notification(notification_id))._selector().length).toEqual 1

    describe "when notification does not exist", ->

      it "returns object with length 0", ->
        some_random_id = "abc123"
        expect((new Notification(some_random_id))._selector().length).toEqual 0
