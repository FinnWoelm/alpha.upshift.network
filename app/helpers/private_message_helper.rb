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

end
