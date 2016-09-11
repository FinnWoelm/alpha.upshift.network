class PendingNewsletterSubscriptionsController < ApplicationController

  def create
    @pending_newsletter_subscription =
      PendingNewsletterSubscription.find_by_email(pending_newsletter_subscription_params[:email]) ||
      PendingNewsletterSubscription.new(pending_newsletter_subscription_params)

    @pending_newsletter_subscription.name =
      pending_newsletter_subscription_params[:name]
    @pending_newsletter_subscription.ip_address = request.remote_ip
    @pending_newsletter_subscription.signup_url = "http://upshift.network/"
    @pending_newsletter_subscription.regenerate_confirmation_token

    if @pending_newsletter_subscription.save
      render :create
    else
      render :new
    end
  end

  def confirm
    @pending_newsletter_subscription =
      PendingNewsletterSubscription.find_by(
        :email => params[:email],
        :confirmation_token => params[:confirmation_token]
      )

    begin
      raise error unless @pending_newsletter_subscription
      Mailjet::Contactslist_managecontact.create(
        id: 1663798,
        action: "addnoforce",
        email: @pending_newsletter_subscription.email,
        name: @pending_newsletter_subscription.name,
        properties: {
          "ip_address": @pending_newsletter_subscription.ip_address,
          "signup_url": @pending_newsletter_subscription.signup_url,
          "signup_datetime": @pending_newsletter_subscription.updated_at.strftime("%Y-%m-%dT%l:%M:%S%z"),
          "confirmation_datetime": Time.zone.now.strftime("%Y-%m-%dT%l:%M:%S%z"),
          "double_opt_in?": true
        }
      )
      @pending_newsletter_subscription.destroy
      render :confirm
    rescue
      render :error
    end

  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def pending_newsletter_subscription_params
      params.require(:pending_newsletter_subscription).permit(:name, :email)
    end
end
