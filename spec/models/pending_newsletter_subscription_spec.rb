require 'rails_helper'

RSpec.describe PendingNewsletterSubscription, type: :model do

  subject(:pending_newsletter_subscription) do
    build(:pending_newsletter_subscription)
  end

  it "has a valid factory" do
    is_expected.to be_valid
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:ip_address) }
    it { is_expected.to validate_presence_of(:signup_url) }
    it { is_expected.to validate_presence_of(:confirmation_token) }
  end

  describe "#send_confirmation_email" do
    before { allow(Mailjet::Send).to receive(:create) }
    after { pending_newsletter_subscription.send_confirmation_email }

    it "calls confirmation path" do
      expect(pending_newsletter_subscription).to receive(:confirmation_path)
    end

    it "sends an email" do
      confirmation_path = instance_double(String)
      allow(pending_newsletter_subscription).
        to receive(:confirmation_path).and_return( confirmation_path )
      expect(Mailjet::Send).to receive(:create).with(
        "FromEmail": "hello@upshift.network",
        "FromName": "Upshift Network",
        "Subject": "Please Confirm Your Subscription",
        "Mj-TemplateID": "49351",
        "Mj-TemplateLanguage": "true",
        "Mj-trackclick": "1",
        recipients: [{
          'Email' => pending_newsletter_subscription.email,
          'Name' => pending_newsletter_subscription.name}],
        vars: {
          "NAME" => pending_newsletter_subscription.name,
          "CONFIRMATION_PATH" => confirmation_path
        }
      )
    end
  end

  describe "#add_newsletter_subscription" do
    before { allow(Mailjet::Contactslist_managecontact).to receive(:create) }
    after { pending_newsletter_subscription.add_newsletter_subscription }

    it "adds the record to the list of subscribers" do
      expect(Mailjet::Contactslist_managecontact).to receive(:create).with(
        id: 1663798,
        action: "addnoforce",
        email: pending_newsletter_subscription.email,
        name: pending_newsletter_subscription.name,
        properties: {
          "ip_address": pending_newsletter_subscription.ip_address,
          "signup_url": pending_newsletter_subscription.signup_url,
          "signup_datetime": pending_newsletter_subscription.updated_at.strftime("%Y-%m-%dT%l:%M:%S%z"),
          "confirmation_datetime": Time.zone.now.strftime("%Y-%m-%dT%l:%M:%S%z"),
          "double_opt_in?": true
        }
      )
    end

  end

  describe "#confirmation_path" do

    it "returns the url path for confirming the newsletter subscription" do
      expect(pending_newsletter_subscription.send(:confirmation_path)).
        to eq (
          Rails.application.routes.url_helpers.
            confirm_pending_newsletter_subscriptions_path(
              :email => pending_newsletter_subscription.email,
              :confirmation_token => pending_newsletter_subscription.confirmation_token
            )
        )
    end
  end

end
