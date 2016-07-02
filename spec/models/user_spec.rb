require 'rails_helper'

RSpec.describe User, type: :model do

  it { is_expected.to have_secure_password() }

  it "has a valid factory" do
    build(:user).should be_valid
  end

  # For future
  # it "is invalid without an email" do
  #   build(:user, email: nil).should_not be_valid
  # end

end
