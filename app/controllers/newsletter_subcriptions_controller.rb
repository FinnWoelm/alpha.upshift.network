class NewsletterSubcriptionsController < ApplicationController
  def create

    @name = params[:name]
    email = params[:email]

    respond_to do |format|
      if @name.present? && email.present?
        format.js
      else
        format.js { render 'new' }
      end
    end
  end
end
