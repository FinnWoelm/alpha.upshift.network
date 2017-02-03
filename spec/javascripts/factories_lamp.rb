MagicLamp.define(controller: StaticController) do

  fixture do
    @pending_newsletter_subscription = PendingNewsletterSubscription.new
    render :home
  end
end
