class StaticController < ApplicationController

  layout "static_fluid"

  def home
    @pending_newsletter_subscription = PendingNewsletterSubscription.new
  end
end
