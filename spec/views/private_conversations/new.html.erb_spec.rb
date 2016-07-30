require 'rails_helper'

RSpec.describe "private_conversations/new.html.erb", type: :view do

  before(:each) do
    @current_user = create(:user)
  end

  context "New conversation is being created" do

    before(:each) do
      @sender = @current_user
      @recipient = create(:user)
    end

    it "shows error if recipient is invalid" do
      @private_message =
        PrivateMessage.new(
          :sender => @sender,
          :recipient => @recipient.username + "abc",
          :content => Faker::Lorem.paragraph)

      @private_message.build_conversation(:sender => @sender, :recipient => @private_message.recipient)

      @private_message.valid?

      render

      expect(@private_message.errors.size).to eq(1)
      expect(rendered).to have_text("Recipient does not exist or their profile is private")
    end

    it "shows error if recipient profile is private" do

      @recipient.profile.is_private!

      @private_message =
        PrivateMessage.new(
          :sender => @sender,
          :recipient => @recipient.username,
          :content => Faker::Lorem.paragraph)

      @private_message.build_conversation(:sender => @sender, :recipient => @private_message.recipient)

      @private_message.valid?

      render

      expect(@private_message.errors.size).to eq(1)
      expect(rendered).to have_text("Recipient does not exist or their profile is private")
    end

    it "shows error if recipient is missing" do

      @private_message =
        PrivateMessage.new(
          :sender => @sender,
          :recipient => "",
          :content => Faker::Lorem.paragraph)

      @private_message.build_conversation(:sender => @sender, :recipient => @private_message.recipient)

      @private_message.valid?

      render

      expect(@private_message.errors.size).to eq(1)
      expect(rendered).to have_text("Recipient can't be blank")
    end

    it "does not show any other errors" do

      @private_message =
        PrivateMessage.new(
          :sender => @sender,
          :recipient => @recipient.username,
          :content => Faker::Lorem.paragraph)

      @private_message.build_conversation(:sender => @sender, :recipient => @private_message.recipient)

      @private_message.valid?

      @private_message.errors.add :some, "random message that shall not be shown"
      @private_message.errors.add :random, "random message that shall not be shown"
      @private_message.errors.add :message, "random message that shall not be shown"

      render

      expect(@private_message.errors.size).to eq(0)
    end
  end

end
