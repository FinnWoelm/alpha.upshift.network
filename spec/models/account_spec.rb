require 'rails_helper'

RSpec.describe Account, type: :model do

  subject(:account) { build(:account) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  it { is_expected.to have_secure_password }

  describe "associations" do
    it { is_expected.to have_one(:user).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_confirmation_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(8).is_at_most(50) }

    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    context "validates format of email" do
      it "must contain an @ symbol" do
        account.email = "somestringwithoutatsymbol"
        is_expected.to be_invalid
      end

      it "must not contain spaces" do
        account.email = "address@witha space.com"
        is_expected.to be_invalid
      end

      it "passes actual email addresses" do
        account.email = "email@example.com"
        is_expected.to be_valid
      end
    end

    context "on update" do
      before { account.save }

      it "validates the current password" do
        expect(account).to receive(:current_password_matches_password)
        account.valid?
      end
    end
  end

  describe "#current_password" do
    let(:account) { create(:account, :password => "super_secret_password" )}
    after { account.send(:current_password_matches_password) }

    context "when current password matches password" do
      before { account.current_password = "super_secret_password" }

      it "does not add an error message" do
        expect(account.errors[:current_password]).not_to receive(:<<)
      end
    end

    context "when recipient is a String" do
      before { account.current_password = "not_my_password" }

      it "adds an error message" do
        expect(account.errors[:current_password]).to receive(:<<).
          with("does not match your current password")
      end
    end
  end

end
