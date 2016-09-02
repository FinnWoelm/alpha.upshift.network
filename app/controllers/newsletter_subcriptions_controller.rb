class NewsletterSubcriptionsController < ApplicationController
  def create

    @name = params[:name]
    email = params[:email]

    begin
      raise error unless @name.present? && email.present?
      Mailjet::Contactslist_managecontact.create(id: 1663798, action: "addnoforce", email: email, name: @name)
    rescue
      render 'new'
    end
    
  end
end
