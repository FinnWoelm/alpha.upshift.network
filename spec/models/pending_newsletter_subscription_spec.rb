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

end
