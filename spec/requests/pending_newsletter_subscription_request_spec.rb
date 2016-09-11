require 'rails_helper'

RSpec.describe "Pending Newsletter Subscription", type: :request do
  describe "POST #create" do

    it "attempts to create a PendingNewsletterSubscription" do
      expect_any_instance_of(PendingNewsletterSubscription).
        to receive(:save) { true }
      post pending_newsletter_subscriptions_path,
        :params => {
          :pending_newsletter_subscription => {
            :name => Faker::Name.name,
            :email => Faker::Internet.email
          },
         format: :js
        }
    end

  end
end
