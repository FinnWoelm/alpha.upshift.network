require 'rails_helper'

RSpec.describe Post, type: :model do

  it { is_expected.to validate_presence_of(:author) }
  it { is_expected.to validate_presence_of(:content) }
  it { is_expected.to validate_length_of(:content).is_at_most(5000) }

  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  it "retrieves posts in order of most recent to oldest" do
    @user = create(:user)
    5.times { |i| create(:post, :author => @user, :created_at => Time.now - i * 1.day ) }

    time_of_previous_post = Time.now + 100.days
    @user.posts.each do |post|
      expect(post.created_at).to be < time_of_previous_post
      time_of_previous_post = post.created_at
    end
  end

end
