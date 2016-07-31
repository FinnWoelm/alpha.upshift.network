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

  it "can find a friendship between users" do
    3.times { create(:user) }

    # user 1 is friends with user 2
    Friendship.create(:initiator => User.first, :acceptor => User.second)

    # user 1 is friends with user 3
    Friendship.create(:acceptor => User.first, :initiator => User.third)

    # test
    friendship_one = Friendship.find_friendship_between(User.first, User.second).first
    friendship_two = Friendship.find_friendship_between(User.first, User.third).first
    friendship_three = Friendship.find_friendship_between(User.second, User.third).first

    expect(friendship_one).to be_present
    expect(friendship_one.initiator_id).to eq(User.first.id)
    expect(friendship_one.acceptor_id).to eq(User.second.id)

    expect(friendship_two).to be_present
    expect(friendship_two.initiator_id).to eq(User.third.id)
    expect(friendship_two.acceptor_id).to eq(User.first.id)

    expect(friendship_three).not_to be_present

    # test the reverse direction
    friendship_one = Friendship.find_friendship_between(User.second, User.first).first
    friendship_two = Friendship.find_friendship_between(User.third, User.first).first
    friendship_three = Friendship.find_friendship_between(User.third, User.second).first

    expect(friendship_one).to be_present
    expect(friendship_one.initiator_id).to eq(User.first.id)
    expect(friendship_one.acceptor_id).to eq(User.second.id)

    expect(friendship_two).to be_present
    expect(friendship_two.initiator_id).to eq(User.third.id)
    expect(friendship_two.acceptor_id).to eq(User.first.id)

    expect(friendship_three).not_to be_present
  end

end
