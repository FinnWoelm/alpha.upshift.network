class PendingNewsletterSubscriptionsController < ApplicationController

  layout "static_info_message", except: [:create]

  def create
    @pending_newsletter_subscription =
      PendingNewsletterSubscription.find_by_email(pending_newsletter_subscription_params[:email]) ||
      PendingNewsletterSubscription.new(pending_newsletter_subscription_params)

    @pending_newsletter_subscription.name =
      pending_newsletter_subscription_params[:name]
    @pending_newsletter_subscription.ip_address = request.remote_ip
    @pending_newsletter_subscription.signup_url = "http://upshift.network/"

    if @pending_newsletter_subscription.save
      @pending_newsletter_subscription.send_confirmation_email
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

    if @pending_newsletter_subscription
      @pending_newsletter_subscription.add_newsletter_subscription
      @pending_newsletter_subscription.destroy
      render :confirm
    else
      render :error
    end

  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def pending_newsletter_subscription_params
      params.require(:pending_newsletter_subscription).permit(:name, :email)
    end
end
