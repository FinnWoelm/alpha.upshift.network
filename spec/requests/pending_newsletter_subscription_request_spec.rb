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

  describe "GET #confirm" do
    let(:pending_newsletter_subscription) { create(:pending_newsletter_subscription) }
    let(:perform_request) do
      get confirm_pending_newsletter_subscriptions_path,
        :params => {
          :email => pending_newsletter_subscription.email,
          :confirmation_token => pending_newsletter_subscription.confirmation_token
        }
    end

    it "finds the pending newsletter subscription" do
      perform_request
      expect(@controller.instance_variable_get(:@pending_newsletter_subscription).id).
        to eq(pending_newsletter_subscription.id)
    end

    context "when pending_newsletter_subscription is found" do
      before do
        allow(PendingNewsletterSubscription).
          to receive(:find_by) { pending_newsletter_subscription }
        perform_request
      end

      it { is_expected.to render_template :confirm }

      it "destroys the pending newsletter subscription" do
        expect(PendingNewsletterSubscription).
          not_to exist(pending_newsletter_subscription.id)
      end
    end

    context "when pending_newsletter_subscription is not found" do
      before do
        allow(PendingNewsletterSubscription).
          to receive(:find_by) { nil }
        perform_request
      end

      it { is_expected.to render_template :error }

    end

  end
end
