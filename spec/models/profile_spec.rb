require 'rails_helper'

RSpec.describe Profile, type: :model do

  subject(:profile) { build_stubbed(:profile) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:user).dependent(false).inverse_of(:profile) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:user) }
  end

end
