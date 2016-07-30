module PrivateMessageHelper

  # renders the profile of the sender without requiring another database call
  # since conversation participants should already be loaded at this point
  def render_sender_profile private_message

    # is the message from the current user?
    return "you" if private_message.sender_id == @current_user.id

    # is the message from the conversation partner?

    private_message.conversation.participants.each do |participant|
      return participant.name if private_message.sender_id == participant.id
    end

    # fallback
    return private_message.sender.name

  end


  # First we will iterate through all error messages. We filter out all those
  # that belong to associated objects and transform them into "does not exist
  # or profile is private". Otherwise, the type of error message will indicate
  # to the sender whether the recipient's profile is actually private or the
  # user does not exist.
  def filter_errors private_message

    error_keys_to_transform = [
      {:from => :"conversation.recipient", :to => :"recipient"}
    ]

    whitedlisted_error_keys = [
      :"recipient",
      :"content"
    ]

    # Transform
    error_keys_to_transform.each do |key|
      private_message.errors[key[:from]].map { |msg|
        private_message.errors.add(key[:to], msg)
      }
      private_message.errors.delete key[:from]
    end

    # Whitelist
    private_message.errors.keys.clone.each do |key|

      # delete everything that's not whitelisted
      if not whitedlisted_error_keys.include? key
        private_message.errors.delete key
      end

    end

    # Custom Transformations
    if private_message.errors.has_key? :recipient
      private_message.errors.delete :recipient
      if not private_message.recipient_username.empty?
        private_message.errors.add :recipient, "does not exist or their profile is private"
      else
        private_message.errors.add :recipient, "can't be blank"
      end
    end


  end

end
