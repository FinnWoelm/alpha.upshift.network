require 'rails_helper'

RSpec.describe User, type: :model do

  it { is_expected.to have_secure_password() }

  it "has a valid factory" do
    build(:user).should be_valid
  end

  it "is invalid with illegal username" do
    build(:user, :username => "some.username").should_not be_valid
  end

end
