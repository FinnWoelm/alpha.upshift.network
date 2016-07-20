require 'rails_helper'

RSpec.describe Friendship, type: :model do

  it { is_expected.to validate_presence_of(:initiator) }
  it { is_expected.to validate_presence_of(:acceptor) }

  it "has a valid factory" do
    expect(build(:friendship)).to be_valid
  end

  it "is accessible to both users" do
    friendship = create(:friendship)
    initiator = friendship.initiator
    acceptor = friendship.acceptor
    expect(initiator.friends.size).to eq(1)
    expect(acceptor.friends.size).to eq(1)
  end

  it "can only be created once (it is unique)" do
    friendship = create(:friendship)
    same_friendship =
      build(
        :friendship,
        :initiator => friendship.initiator,
        :acceptor => friendship.acceptor
      )
    expect(same_friendship).not_to be_valid
    expect(same_friendship.errors.full_messages).
      to include("You are already friends with #{same_friendship.initiator.name}")
  end

  it "cannot be created in both directions by the same users" do
    friendship = create(:friendship)
    inverse_friendship =
      build(
        :friendship,
        :initiator => friendship.acceptor,
        :acceptor => friendship.initiator
      )

    expect(inverse_friendship).to be_invalid
    expect(inverse_friendship.errors.full_messages).
      to include("You are already friends with #{inverse_friendship.initiator.name}")
  end

end
