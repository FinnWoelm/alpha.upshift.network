require 'rails_helper'

RSpec.describe Democracy::Community, type: :model do

  subject(:community) { build_stubbed(:democracy_community) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

end
