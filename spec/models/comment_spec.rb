require 'rails_helper'

RSpec.describe Comment, type: :model do

  it { is_expected.to validate_presence_of(:author) }
  it { is_expected.to validate_presence_of(:post) }
  it { is_expected.to validate_presence_of(:content) }
  it { is_expected.to validate_length_of(:content).is_at_most(1000) }

  it "has a valid factory" do
    expect(build(:comment)).to be_valid
  end

  it "cannot be added if user cannot see post" do
    @post = create(:post)
    @post.author.profile.is_private!
    @comment = build(:comment, :post => @post)
    expect(@comment).not_to be_valid
    expect(@comment.errors.full_messages).
      to include("An error occurred. Either the post never existed, it does not
      exist anymore, or the author's profile privacy settings have changed.")
  end

end
