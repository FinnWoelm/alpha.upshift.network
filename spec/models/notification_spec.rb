require 'rails_helper'

RSpec.describe Notification, type: :model do

  subject(:notification) { build(:notification) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:notifier).dependent(false) }
    it { is_expected.to have_many(:actions).
      class_name("Notification::Action").dependent(:delete_all) }
    it { is_expected.to have_many(:actors).dependent(false).
      through(:actions).source(:actor) }
    it { is_expected.to have_many(:subscriptions).
      class_name("Notification::Subscription").dependent(:delete_all) }
    it { is_expected.to have_many(:subscribers).dependent(false).
      through(:subscriptions).source(:subscriber) }
  end

  describe "accessors" do
    it {
      is_expected.to define_enum_for(:action_on_notifier).
        with([:post, :comment, :like])
    }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:notifier).with_message("must exist") }
  end
end
