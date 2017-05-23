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
  end

end
