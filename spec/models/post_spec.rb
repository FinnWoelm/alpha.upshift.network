require 'rails_helper'

RSpec.describe Post, type: :model do

  it { is_expected.to validate_presence_of(:author) }
  it { is_expected.to validate_presence_of(:content) }
  it { is_expected.to validate_length_of(:content).is_at_most(5000) }

  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

end
