require 'rails_helper'

RSpec.describe Notification::Subscription, type: :model do

  subject(:notification_subscription) { build(:notification_subscription) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:notification).dependent(false) }
    it { is_expected.to belong_to(:subscriber).class_name("User").
      dependent(false) }
  end

  describe "accessors" do
    it {
      is_expected.to define_enum_for(:reason_for_subscription).
        with([:author, :recipient, :commenter, :follower])
    }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:notification).with_message("must exist") }
    it { is_expected.to validate_presence_of(:subscriber).with_message("must exist") }
  end

end
