module NotificationsHelper

  # parses the notification's actors, action, notifier, and subscription reason
  # into the notification title text
  def notification_title actors, other_actors, action, notifier, subscription_reason
    # start with the actors
    actors = actors.map(&:name)
    # have others also acted?
    actors += ["others"] if other_actors

    notification_text = actors.to_sentence + " "

    # add the action
    notification_text += case action.to_sym
    when :post
      "posted on your profile"
    when :comment
      "#{subscription_reason.to_sym == :commenter ? 'also ' : ''}commented on :object"
    when :like
      "liked :object"
    end

    # add the subscription reason and notifier
    notification_text.gsub!(
      ":object",
      case subscription_reason.to_sym
      when :author
         "your #{notifier.model_name.to_s.downcase}"
      when :recipient
        "a #{notifier.model_name.to_s.downcase} on your profile"
      when :commenter
        "a post"
      end
    )

    notification_text
  end

  def notification_subtitle notifier
    case notifier.model_name.to_s.downcase.to_sym
    when :post, :comment
      notifier.content.truncate(50)
    end
  end

  def path_to_notification_notifier notification

    path  = notification.notifier_type.downcase + "_path"
    id    = notification.notifier_id

    if notification.notifier_type.downcase == "comment"
      path  = notification.notifier.commentable_type.downcase + "_path"
      id    = notification.notifier.commentable_id
    end

    Rails.application.routes.url_helpers.send(path.to_sym, id)
  end

end
