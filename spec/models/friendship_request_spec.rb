require 'rails_helper'

RSpec.describe FriendshipRequest, type: :model do

  it { is_expected.to validate_presence_of(:sender) }
  it { is_expected.to validate_presence_of(:recipient) }

  it "has a valid factory" do
    expect(build(:friendship_request)).to be_valid
  end

  it "is accessible to both users" do
    request = create(:friendship_request)
    sender = request.sender
    recipient = request.recipient
    expect(sender.friendship_requests_sent.size).to eq(1)
    expect(recipient.friendship_requests_received.size).to eq(1)
  end

  it "can only be created once (it is unique)" do
    request = create(:friendship_request)
    same_request =
      build(
        :friendship_request,
        :sender => request.sender,
        :recipient => request.recipient
      )
    expect(same_request).not_to be_valid
    expect(same_request.errors.full_messages).to
      include("You have already sent a friend request to this user")
  end

  it "cannot be created in both directions by the same users" do
    request = create(:friendship_request)
    inverse_request =
      build(
        :friendship_request,
        :sender => request.recipient,
        :recipient => request.sender
      )

    pending "expect: create friendship right away"
  end

end
