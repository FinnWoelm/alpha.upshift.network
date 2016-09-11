class StaticController < ApplicationController
  def home
    @pending_newsletter_subscription = PendingNewsletterSubscription.new
  end
end
