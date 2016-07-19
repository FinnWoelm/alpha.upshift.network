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


end
