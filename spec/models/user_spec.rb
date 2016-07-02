require 'rails_helper'

RSpec.describe User, type: :model do

  it { is_expected.to have_secure_password() }

  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  # Usrenames

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
