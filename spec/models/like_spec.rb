require 'rails_helper'

RSpec.describe Like, type: :model do

  it { is_expected.to validate_presence_of(:liker) }
  it { is_expected.to validate_presence_of(:likable_id) }
  it { is_expected.to validate_presence_of(:likable_type) }
  it { is_expected.to validate_inclusion_of(:likable_type).in_array(Like.likable_types) }

  it "has a valid factory" do
    expect(build(:like, :likable => create(:post))).to be_valid
  end

end
