require 'rails_helper'

RSpec.describe User, type: :model do

  subject(:user) { build(:user) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  it { is_expected.to have_secure_password }
  it { should have_attached_file(:profile_picture) }

  describe "associations" do
    it { is_expected.to have_one(:profile).dependent(:destroy).
      inverse_of(:user)}
    it { is_expected.to have_many(:posts).dependent(:destroy).
      with_foreign_key("author_id")}
    it { is_expected.to have_many(:comments).dependent(:destroy).
      with_foreign_key("author_id")}

    it { is_expected.to have_many(:likes).dependent(:destroy).
      with_foreign_key("liker_id")}

    it { is_expected.to have_many(:participantships_in_private_conversations).
      dependent(:destroy).class_name("ParticipantshipInPrivateConversation").
      with_foreign_key("participant_id").inverse_of(:participant) }
    it { is_expected.to have_many(:private_conversations).dependent(false).
      through(:participantships_in_private_conversations).
      source(:private_conversation) }

    it { is_expected.to have_many(:private_messages_sent).dependent(:destroy).
      class_name("PrivateMessage").with_foreign_key("sender_id").
      inverse_of(:sender) }

    it { is_expected.to have_many(:friendship_requests_sent).
      dependent(:destroy).class_name("FriendshipRequest").
      with_foreign_key("sender_id") }
    it { is_expected.to have_many(:friendship_requests_received).
      dependent(:destroy).class_name("FriendshipRequest").
      with_foreign_key("recipient_id") }

    it { is_expected.to have_many(:friendships_initiated).
      dependent(:destroy).class_name("Friendship").
      with_foreign_key("initiator_id") }
    it { is_expected.to have_many(:friendships_accepted).
      dependent(:destroy).class_name("Friendship").
      with_foreign_key("acceptor_id") }

    it { is_expected.to have_many(:friends_found).dependent(false).
      through(:friendships_initiated).source(:acceptor) }
    it { is_expected.to have_many(:friends_made).dependent(false).
      through(:friendships_accepted).source(:initiator) }

  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:profile) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_confirmation_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(8).is_at_most(50) }

    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    context "validates format of email" do
      it "must contain an @ symbol" do
        user.email = "somestringwithoutatsymbol"
        is_expected.to be_invalid
      end

      it "must not contain spaces" do
        user.email = "address@witha space.com"
        is_expected.to be_invalid
      end

      it "passes actual email addresses" do
        user.email = "email@example.com"
        is_expected.to be_valid
      end

    end

    it { is_expected.to validate_length_of(:username).is_at_least(3).is_at_most(26) }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }

    context "validates format of username" do
      it "must not contain special characters" do
        user.username = "a*<>$@/r"
        is_expected.to be_invalid
      end

      it "must not begin with an underscore" do
        user.username = "_" + user.username
        is_expected.to be_invalid
      end

      it "must not end with an underscore" do
        user.username += "_"
        is_expected.to be_invalid
      end

    end

    context "validates profile picture" do

      it do
        is_expected.to validate_attachment_content_type(:profile_picture).
          allowing('image/png', 'image/gif', 'image/jpeg').
          rejecting('text/plain', 'text/xml', 'application/pdf')
      end

      it do
        is_expected.to validate_attachment_size(:profile_picture).
          less_than(1.megabytes)
      end
    end

    context "validates color_scheme" do
      it { is_expected.to validate_inclusion_of(:color_scheme).
        in_array(Color.color_options) }
    end
  end

  describe "callbacks" do

    describe "after create" do

      subject(:user) { build(:user) }
      after { user.save }

      it { is_expected.to receive(:generate_fallback_profile_picture).and_call_original }
      it { is_expected.to receive(:generate_symlink_for_fallback_profile_picture) }
    end

    describe "after update (commit)" do

      subject!(:user) { create(:user) }

      after { user.save }

      context "when name was updated" do
        after { user.name = "Something..." }
        it { is_expected.to receive(:generate_fallback_profile_picture) }
      end

      context "when color_scheme was updated" do
        after { user.color_scheme = Color.color_options.sample }
        it { is_expected.to receive(:generate_fallback_profile_picture) }
      end

      context "when profile_picture was updated and set to nil" do
        before do
          user.profile_picture = File.new(
            "#{Rails.root}/spec/support/fixtures/community/user/profile_picture.png"
          )
          user.save
        end
        after do
          user.profile_picture = nil
        end
        it { is_expected.to receive(:generate_symlink_for_fallback_profile_picture) }
      end
    end

    describe "before save" do

      subject!(:user) { create(:user) }
      before { user.profile_picture_updated_at = nil }
      after { user.save }

      context "when profile_picture_updated_at is nil" do
        it { is_expected.to receive(:set_profile_picture_updated_at) }
      end
    end
  end

  describe "#to_param" do
    it "returns the username" do
      expect(user.to_param).to eq(user.username)
    end
  end

  describe "#color_scheme_with_font_color" do

    it "returns the color scheme" do
      expect(user.color_scheme_with_font_color).to include(user.color_scheme)
    end

    it "returns the font color" do
      expect(user.color_scheme_with_font_color).to include(
        Color.font_color_for(user.color_scheme)
      )
    end
  end

  describe "#friends" do
    let(:friends_made) { build_stubbed_list(:user, 3) }
    let(:friends_found) { build_stubbed_list(:user, 3) }
    before do
      user.friends_made = friends_made
      user.friends_found = friends_found
    end

    it "returns friends found and friends made" do
      expect(user.friends).to match_array(friends_made + friends_found)
    end

  end

  describe "#has_friendship_with?" do
    let(:other_user) { build_stubbed(:user) }

    context "when user has friendship" do
      before { allow(user).to receive(:friends) { [other_user] } }

      it "returns true" do
        is_expected.to have_friendship_with other_user
      end
    end

    context "when user does not have friendship" do
      before { allow(user).to receive(:friends) { [] } }

      it "returns false" do
        is_expected.not_to have_friendship_with other_user
      end
    end
  end

  describe "#has_received_friend_request_from?" do
    let(:other_user) { build(:user) }

    context "when user has received friend request" do
      before do
        create(:friendship_request, :sender => other_user, :recipient => user)
      end

      it "returns true" do
        is_expected.to have_received_friend_request_from other_user
      end
    end

    context "when user does not have received friend request" do
      before { FriendshipRequest.destroy_all }

      it "returns false" do
        is_expected.not_to have_received_friend_request_from other_user
      end
    end
  end

  describe "#has_sent_friend_request_to?" do
    let(:other_user) { build(:user) }

    context "when user has sent friend request" do
      before do
        create(:friendship_request, :sender => user, :recipient => other_user)
      end

      it "returns true" do
        is_expected.to have_sent_friend_request_to other_user
      end
    end

    context "when user does not have sent friend request" do
      before { FriendshipRequest.destroy_all }

      it "returns false" do
        is_expected.not_to have_sent_friend_request_to other_user
      end
    end
  end

  describe "#generate_fallback_profile_picture" do

    subject!(:user) { create(:user) }

    it "generates an avatar using Avatarly " do
      expect(Avatarly).to receive(:generate_avatar).and_return("encoded_image")
      user.generate_fallback_profile_picture
    end

    it "passes the user's name" do
      expect(Avatarly).to receive(:generate_avatar).with(user.name, anything).
        and_return("encoded_image")
      user.generate_fallback_profile_picture
    end

    it "sets size to 250px" do
      expect(Avatarly).to receive(:generate_avatar).with(
        anything,
        hash_including(:size => 250)
      ).and_return("encoded_image")
      user.generate_fallback_profile_picture
    end

    it "passes the user's color_scheme for background_color" do
      hex_color = Color.convert_to_hex(user.color_scheme)
      expect(Avatarly).to receive(:generate_avatar).with(
        anything,
        hash_including(:background_color => hex_color)
      ).and_return("encoded_image")
      user.generate_fallback_profile_picture
    end

    it "passes the font color for the user's color_scheme for font_color" do
      hex_color = Color.convert_to_hex(Color.font_color_for(user.color_scheme))
      expect(Avatarly).to receive(:generate_avatar).with(
        anything,
        hash_including(:font_color => hex_color)
      ).and_return("encoded_image")
      user.generate_fallback_profile_picture
    end

    it "saves the file to storage" do
      path_to_file = "#{Rails.root}/public#{user.profile_picture.url}".rpartition('/').first + "/fallback.jpg"
      # remove file if it exists
      if FileTest.exist?(path_to_file)
        FileUtils.remove_file(path_to_file)
      end
      user.generate_fallback_profile_picture
      expect(FileTest.exist?(path_to_file)).to be_truthy
    end
  end

  describe "#unread_private_conversations" do
    before { user.save }
    let!(:conversations) { create_list(:private_conversation, 5, :sender => user) }

    it "returns conversations in the order of most recent activity" do
      expect(user.private_conversations).
      to receive(:most_recent_activity_first) { user.private_conversations }
      user.unread_private_conversations
    end

    it "returns conversations that were never read" do
      set_last_read_of_participantships { nil }
      expect(user.unread_private_conversations).to match_array(conversations)
    end

    it "returns conversations that are unread" do
      set_last_read_of_participantships do |p|
        p.private_conversation.updated_at - 1.second
      end
      expect(user.unread_private_conversations).to match_array(conversations)
    end

    it "does not return read conversations" do
      set_last_read_of_participantships{ |p| p.private_conversation.updated_at }
      expect(user.unread_private_conversations).to eq( [] )
    end

    def set_last_read_of_participantships
      user.participantships_in_private_conversations.each do |participantship|
        participantship.update_attributes(read_at: yield(participantship) )
      end
    end

  end

  describe ".to_user" do

    context "when input is a string" do
      let(:user) { create(:user) }

      it "returns the user" do
        expect(User.to_user(user.username)).to eq(user)
      end
    end

    context "when input is a User" do
      let(:user) { create(:user) }

      it "returns the user" do
        expect(User.to_user(user)).to eq(user)
      end
    end

    context "when input is a number" do
      it "raises an error" do
        expect{ User.to_user(1) }.to raise_error(ArgumentError)
      end
    end

    context "when input is nil" do
      it "returns nil" do
        expect(User.to_user(nil)).to be_nil
      end
    end

  end

  describe "#send_registration_email" do
    before { allow(Mailjet::Send).to receive(:create) }
    after { user.send_registration_email }

    it "calls registration confirmation path" do
      expect(user).to receive(:registration_confirmation_path)
    end

    it "sends an email" do
      registration_confirmation_path = instance_double(String)
      allow(user).
        to receive(:registration_confirmation_path).
        and_return( registration_confirmation_path )
      expect(Mailjet::Send).to receive(:create).with(
        "FromEmail": "hello@upshift.network",
        "FromName": "Upshift Network",
        "Subject": "Please Confirm Your Registration",
        "Mj-TemplateID": ENV['USER_REGISTRATION_EMAIL_TEMPLATE_ID'],
        "Mj-TemplateLanguage": "true",
        "Mj-trackclick": "1",
        recipients: [{
          'Email' => user.email,
          'Name' => user.name}],
        vars: {
          "NAME" => user.name,
          "CONFIRMATION_PATH" => registration_confirmation_path
        }
      )
    end
  end

  describe "#registration_confirmation_path" do

    it "returns the url path for confirming the user registration" do
      expect(user.send(:registration_confirmation_path)).
        to eq (
          Rails.application.routes.url_helpers.
            confirm_registration_path(
              :email => user.email,
              :registration_token => user.registration_token
            )
        )
    end
  end

end
