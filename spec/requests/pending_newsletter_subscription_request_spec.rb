require 'rails_helper'

RSpec.describe "Pending Newsletter Subscription", type: :request do

  describe "POST #create" do
    let(:pending_newsletter_subscription) { assigns(:pending_newsletter_subscription) }
    let(:email) { Faker::Internet.email }
    let(:name) { Faker::Name.name }
    let(:confirmation_token) { Faker::Internet.password }
    let(:ip_address) { Faker::Internet.ip_v4_address }
    let(:perform_request) do
      post pending_newsletter_subscriptions_path,
        :params => {
          :pending_newsletter_subscription => {
            :name => name,
            :email => email
          },
          format: :js
        }
    end
    before do
      allow_any_instance_of(PendingNewsletterSubscription).
        to receive(:send_confirmation_email)
    end

    describe "assignments" do

      context "when a pending newsletter subscription for the email exists" do
        let(:existing_pns) do
          create(:pending_newsletter_subscription, :email => email)
        end
        before do
          allow(PendingNewsletterSubscription).
            to receive(:find_by_email).and_return( existing_pns )
        end

        it "assigns the existing record" do
          perform_request
          expect(pending_newsletter_subscription).to eq existing_pns
        end
      end

      context "when a pending newsletter subscription for the email does not exist" do
        before do
          allow(PendingNewsletterSubscription).
            to receive(:find_by_email).and_return( nil )
        end

        it "assigns a new record" do
          expect(PendingNewsletterSubscription).
            to receive(:new).and_return( build(:pending_newsletter_subscription) )
          perform_request
        end
      end

      it "assigns the name" do
        perform_request
        expect(pending_newsletter_subscription.name).to eq name
      end

      it "assigns the IP address" do
        allow_any_instance_of(ActionDispatch::Request).
          to receive(:remote_ip).and_return(ip_address)
        perform_request
        expect(pending_newsletter_subscription.ip_address).to eq ip_address
      end

      it "assigns the signup url" do
        perform_request
        expect(pending_newsletter_subscription.signup_url).to eq "http://upshift.network/"
      end

      it "sets a confirmation token" do
        expect_any_instance_of(PendingNewsletterSubscription).
          to receive(:regenerate_confirmation_token)
        perform_request
      end

    end

    describe "actions" do
      it "attempts to save a PendingNewsletterSubscription" do
        expect_any_instance_of(PendingNewsletterSubscription).
          to receive(:save)
        perform_request
      end

      context "when PendingNewsletterSubscription is persisted" do
        before do
          allow_any_instance_of(PendingNewsletterSubscription).
            to receive(:save).and_return( true )
        end

        it "sends a confirmation email" do
          expect_any_instance_of(PendingNewsletterSubscription).
            to receive(:send_confirmation_email)
          perform_request
        end
      end

      context "when PendingNewsletterSubscription is not persisted" do
        before do
          allow_any_instance_of(PendingNewsletterSubscription).
            to receive(:save).and_return( false )
        end

        it "sends a confirmation email" do
          expect_any_instance_of(PendingNewsletterSubscription).
            not_to receive(:send_confirmation_email)
          perform_request
        end
      end
    end

    describe "templates" do
      before do
        allow_any_instance_of(PendingNewsletterSubscription).
          to receive(:save).and_return( result )
        perform_request
      end

      context "when PendingNewsletterSubscription is persisted" do
        let(:result) { true }

        it { is_expected.to render_template :create }
      end

      context "when PendingNewsletterSubscription is not persisted" do
        let(:result) { false }

        it { is_expected.to render_template :new }
      end
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
    before do
      allow_any_instance_of(PendingNewsletterSubscription).
        to receive(:add_newsletter_subscription)
    end

    describe "assignments" do

      it "finds the pending newsletter subscription" do
        perform_request
        expect(assigns(:pending_newsletter_subscription).id).
          to eq(pending_newsletter_subscription.id)
      end
    end

    describe "actions" do
      context "when PendingNewsletterSubscription is present" do
        before do
          allow(PendingNewsletterSubscription).
            to receive(:find_by).and_return( pending_newsletter_subscription )
        end

        it "adds subscription to newsletter list" do
          expect_any_instance_of(PendingNewsletterSubscription).
            to receive(:add_newsletter_subscription)
          perform_request
        end

        it "destroys the pending subscription" do
          expect_any_instance_of(PendingNewsletterSubscription).
            to receive(:destroy)
          perform_request
        end
      end

      context "when PendingNewsletterSubscription is nil" do
        before do
          allow(PendingNewsletterSubscription).
            to receive(:find_by).and_return( nil )
        end

        it "does not add subscription to newsletter list" do
          expect_any_instance_of(PendingNewsletterSubscription).
            not_to receive(:add_newsletter_subscription)
          perform_request
        end

        it "does not destroy the pending subscription" do
          expect_any_instance_of(PendingNewsletterSubscription).
            not_to receive(:destroy)
          perform_request
        end
      end
    end

    describe "templates" do
      before do
        allow(PendingNewsletterSubscription).
          to receive(:find_by).and_return( result )
        perform_request
      end

      context "when PendingNewsletterSubscription is found" do
        let(:result) { pending_newsletter_subscription }

        it { is_expected.to render_template :confirm }
        it { is_expected.to render_template :layout => "static_info_message" }
      end

      context "when PendingNewsletterSubscription is not found" do
        let(:result) { nil }

        it { is_expected.to render_template :error }
        it { is_expected.to render_template :layout => "static_info_message" }
      end
    end


  end
end
