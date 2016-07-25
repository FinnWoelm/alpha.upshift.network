require 'rails_helper'

RSpec.describe User, type: :model do

  it { is_expected.to have_secure_password() }

  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  # Profile

  it "creates a profile on create" do
    u = create(:user)
    expect(u.profile).to be_present
  end

  it "does not create a profile if one already exists" do
    profile = Profile.create
    u = create(:user, :profile => profile)
    expect(u.profile.id).to eq(profile.id)
  end

  it "deletes the profile when it is destroyed" do
    u = create(:user)
    p = u.profile
    u.destroy
    expect{p.reload}.to raise_error(ActiveRecord::RecordNotFound)
  end

  # Usernames

  it "is invalid with illegal username" do
    expect(build(:user, :username => Faker::Internet.email)).not_to be_valid
  end

  it "username cannot start or end with underscore" do
    expect(build(:user, :username => "_username")).not_to be_valid
    expect(build(:user, :username => "username_")).not_to be_valid
  end

  it "username must be between 3 and 26 characters long" do
    expect(build(:user, :username => Faker::Lorem.characters(2))).not_to be_valid
    expect(build(:user, :username => Faker::Lorem.characters(27))).not_to be_valid

    expect(build(:user, :username => Faker::Lorem.characters(3))).to be_valid
    expect(build(:user, :username => Faker::Lorem.characters(14))).to be_valid
    expect(build(:user, :username => Faker::Lorem.characters(26))).to be_valid
  end

  it "can find user regardless of capitalization of username" do
    user = create(:user, :username => "sOmeUserNaME")

    expect(User.find_by_username(user.username)).to be_present
    expect(User.find_by_username(user.username.downcase)).to be_present
    expect(User.find_by_username(user.username.upcase)).to be_present
  end

  # Private conversations
  it "can get unread private conversations" do

    @current_user = create(:user)

    @my_conversations = []
    5.times do
      @my_conversations << create(:private_conversation, :sender => @current_user)
    end

    @unread_conversations = []
    20.times do
      conversation = @my_conversations[rand(0..@my_conversations.size-1)]
      sender = conversation.participants[rand(0..1)]
      create(:private_message, :conversation => conversation, :sender => sender)

      # remove conversation in any case (we'll add it to front of queue again
      # in a second as long as the sender wasn't @current_user)
      @unread_conversations -= [conversation]

      # track conversation if it was not sent by current user
      if sender.id != @current_user.id
        @unread_conversations.unshift conversation
      end
    end

    @unread_conversations_to_test = @current_user.unread_private_conversations

    expect(@unread_conversations.size).to eq(@unread_conversations_to_test.size)

    # check each element
    @unread_conversations.each_with_index do |conversation, i|
      expect(conversation.id).to eq(@unread_conversations_to_test[i].id)
    end

    # check each element
    @unread_conversations_to_test.each_with_index do |conversation, i|
      expect(conversation.id).to eq(@unread_conversations[i].id)
    end

  end


end
