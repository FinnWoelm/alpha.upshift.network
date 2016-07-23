require 'rails_helper'

RSpec.describe Like, type: :model do

  it { is_expected.to validate_presence_of(:liker) }
  it { is_expected.to validate_presence_of(:likable_id) }
  it { is_expected.to validate_presence_of(:likable_type) }
  it { is_expected.to validate_inclusion_of(:likable_type).in_array(Like.likable_types) }

  it "has a valid factory" do
    expect(build(:like, :likable => create(:post))).to be_valid
  end

  it "prevents users from liking the same content multiple times" do
    @user = create(:user)
    @post = create(:post)
    create(:like, :likable => @post, :liker => @user)
    same_like = build(:like, :likable => @post, :liker => @user)
    expect(same_like).not_to be_valid
    expect(same_like.errors.full_messages).
      to include("You have already liked this #{same_like.likable_type.downcase}")
  end

end
