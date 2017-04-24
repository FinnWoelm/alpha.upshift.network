require 'rails_helper'

RSpec.describe Notification::Action, type: :model do

  subject(:notification_action) { build(:notification_action) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:notification).dependent(false) }
    it { is_expected.to belong_to(:actor).class_name("User").
      dependent(false) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:notification).with_message("must exist") }
    it { is_expected.to validate_presence_of(:actor).with_message("must exist") }
  end

  describe "callbacks" do

    describe "after save" do
      after { notification_action.save }

      it { is_expected.to receive(:limit_actions_to_3) }
    end

    describe "before create" do
      let!(:past_action) do
        create(:notification_action,
          :notification => notification_action.notification,
          :actor => notification_action.actor)
      end

      it "deletes existing actions for same notification and user" do
        expect{ notification_action.save }.not_to change(Notification::Action, :count)
        expect(Notification::Action).not_to exist(past_action.id)
      end
    end
  end

  describe "#limit_actions_to_3" do
    let(:notification) { create(:notification) }

    it "keeps only the three most recent actors" do
      5.times do
        notification.actions.create(:actor => create(:user))
      end
      expect(notification.actions.size).to eq 3
    end

    it "sets others_acted_before to the timestamp of the removed actor" do
      first_action_at =
        notification.actions.create(:actor => create(:user)).updated_at
      3.times do
        notification.actions.create(:actor => create(:user))
      end
      expect(notification.reload.others_acted_before.exact).to eq first_action_at.exact
    end
  end
end
