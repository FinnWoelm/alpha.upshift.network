require 'rails_helper'

RSpec.describe User, type: :model do

  subject(:user) { build(:user) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  it { is_expected.to have_secure_password }
  it { is_expected.to have_attached_file(:profile_picture) }
  it { is_expected.to have_attached_file(:profile_banner) }
  it { is_expected.to have_readonly_attribute(:username)}

  describe "associations" do

    it { is_expected.to have_many(:posts_made).class_name("Post").
      dependent(:destroy).with_foreign_key("author_id") }
    it { is_expected.to have_many(:posts_received).class_name("Post").
      dependent(:destroy).with_foreign_key("recipient_id") }

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

    it { is_expected.to have_many(:notification_actions).
      class_name("Notification::Action").dependent(:delete_all).
      with_foreign_key("actor_id") }
    it { is_expected.to have_many(:notifications_created).dependent(false).
      through(:notification_actions).source(:notification) }
    it { is_expected.to have_many(:notification_subscriptions).
      class_name("Notification::Subscription").dependent(:delete_all).
      with_foreign_key("subscriber_id") }

  end

  describe "accessors" do
    it {
      is_expected.to define_enum_for(:visibility).
        with([:private, :network, :public])
    }
  end

  describe "scopes" do

    describe ":viewable_by_user" do

      let(:user) { create(:user, :visibility => "private") }
      let(:public_users) { create_list(:user, 3, :visibility => "public") }
      let(:in_network_users) { create_list(:user, 3, :visibility => "network") }
      let(:private_users) { create_list(:user, 3, :visibility => "private") }
      let(:private_users_who_are_not_friends) { private_users }
      let(:private_users_who_are_friends) { create_list(:friendship, 3, initiator: user).map(&:acceptor) }

      context "when user is not logged in" do
        let(:user) {nil}

        it "returns public users" do
          expect(User.viewable_by_user(user)).to include *public_users
        end

        it "does not return in-network users" do
          expect(User.viewable_by_user(user)).not_to include *in_network_users
        end

        it "does not return private users" do
          expect(User.viewable_by_user(user)).not_to include *private_users
        end
      end

      context "when user is logged in" do

        it "returns public users" do
          expect(User.viewable_by_user(user)).to include *public_users
        end

        it "returns in-network users" do
          expect(User.viewable_by_user(user)).to include *in_network_users
        end

        it "returns private users who are my friends" do
          expect(User.viewable_by_user(user)).to include *private_users_who_are_friends
        end

        it "does not return private users who are not my friends" do
          expect(User.viewable_by_user(user)).not_to include *private_users_who_are_not_friends
        end

        it "returns myself" do
          expect(User.viewable_by_user(user)).to include user
        end
      end
    end

    describe ":with_friends_ids" do

      before { create_list(:friendship, 5) }

      it "returns User records with friends_ids that match Friendship.friends_ids_for" do
        User.with_friends_ids.find_each do |user|
          expect(user.friends_ids).to match_array(Friendship.friends_ids_for(user))
        end
      end
    end
  end

  describe "validations" do
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

    context "validates username" do

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

      it "must not be blacklisted" do
        Helper::BlacklistedUsername.create(:username => user.username)
        is_expected.to be_invalid
      end

      it "must not equal any assigned URL" do
        user.username = Helper::RouteRecognizer.get_initial_path_segments.sample
        is_expected.to be_invalid
      end

      it "must not equal any dictionary words" do
        user.username = "ocean"
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
          less_than(10.megabytes)
      end
    end

    context "validates profile banner" do
      it do
        is_expected.to validate_attachment_content_type(:profile_banner).
          allowing('image/png', 'image/gif', 'image/jpeg').
          rejecting('text/plain', 'text/xml', 'application/pdf')
      end

      it do
        is_expected.to validate_attachment_size(:profile_banner).
          less_than(10.megabytes)
      end
    end

    context "validates color_scheme" do
      it { is_expected.to validate_inclusion_of(:color_scheme).
        in_array(Color.color_options) }
    end
  end

  describe "callbacks" do

    describe "after destroy" do
      subject!(:user) { create(:user) }
      after { user.destroy }

      it { is_expected.to receive(:blacklist_username) }
      it { is_expected.to receive(:delete_attachment_folder) }
    end

    describe "after save" do

      subject!(:user) { create(:user) }
      after { user.save }

      context "when profile_picture was updated" do
        before do
          user.profile_picture = nil
          user.save
        end
        after do
          user.profile_picture = File.new(
            "#{Rails.root}/spec/support/fixtures/community/user/profile_picture.jpg"
          )
        end
        it { is_expected.to receive(:destroy_original_profile_picture) }
      end
    end

    describe "before save" do

      subject!(:user) { create(:user) }
      after { user.save }

      context "when options[:auto_generate_profile_picture] is true" do
        before { user.options[:auto_generate_profile_picture] = true }

        context "when name was updated" do
          after { user.name = "Something..." }
          it { is_expected.to receive(:auto_generate_profile_picture) }
        end

        context "when color_scheme was updated" do
          after { user.color_scheme = Color.color_options.sample }
          it { is_expected.to receive(:auto_generate_profile_picture) }
        end
      end
    end
  end

  describe "#auto_generate_profile_picture" do

    subject!(:user) { create(:user) }

    it "generates an avatar using Avatarly " do
      expect(Avatarly).to receive(:generate_avatar).and_call_original
      user.auto_generate_profile_picture
    end

    it "passes the user's name" do
      expect(Avatarly).to receive(:generate_avatar).with(user.name, anything).
        and_call_original
      user.auto_generate_profile_picture
    end

    it "sets size to 250px" do
      expect(Avatarly).to receive(:generate_avatar).with(
        anything,
        hash_including(:size => 250)
      ).and_call_original
      user.auto_generate_profile_picture
    end

    it "passes the user's color_scheme for background_color" do
      hex_color = Color.convert_to_hex(user.color_scheme)
      expect(Avatarly).to receive(:generate_avatar).with(
        anything,
        hash_including(:background_color => hex_color)
      ).and_call_original
      user.auto_generate_profile_picture
    end

    it "passes the font color for the user's color_scheme for font_color" do
      hex_color = Color.convert_to_hex(Color.font_color_for(user.color_scheme))
      expect(Avatarly).to receive(:generate_avatar).with(
        anything,
        hash_including(:font_color => hex_color)
      ).and_call_original
      user.auto_generate_profile_picture
    end

    it "sets the avatar as profile picture" do
      user.profile_picture_via_paperclip = nil
      user.auto_generate_profile_picture
      expect(user.profile_picture).to be_present
    end

    it "enables the :auto_generate_profile_picture option" do
      user.auto_generate_profile_picture
      expect(user.options[:auto_generate_profile_picture]).to be true
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

  describe "#delete_profile_banner=" do

    let(:user) { build(:user_with_picture) }

    context "when true" do

      it "sets profile banner to nil" do
        user.delete_profile_banner = "true"
        expect(user.profile_banner).not_to be_present
      end
    end
  end

  describe "#delete_profile_picture=" do

    let(:user) { build(:user_with_picture) }

    context "when true" do

      it "auto-generates a profile picture" do
        user.options[:auto_generate_profile_picture] = false
        user.delete_profile_picture = "true"
        expect(user.options[:auto_generate_profile_picture]).to be true
      end
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
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

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
    let(:other_user) { create(:user) }

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

  describe "#posts_made_and_received" do

    it "delegates to Post.made_and_received_by_user" do
      posts = double(ActiveRecord::Relation)
      expect(Post).to receive(:made_and_received_by_user).with(user).and_return(posts)
      expect(user.posts_made_and_received).to eq posts
    end

  end

  describe "#profile_picture=" do
    let(:picture) do
      File.new(
        "#{Rails.root}/spec/support/fixtures/community/user/profile_picture.jpg"
        )
    end

    it "sets the picture via the paperclip setter" do
      expect(user).
        to receive(:"profile_picture_via_paperclip=").with(picture)
      user.profile_picture = picture
    end

    context "when picture is nil" do
      let(:picture) { nil }

      it "auto-generates the profile picture" do
        expect(user).to receive(:auto_generate_profile_picture)
        user.profile_picture = picture
      end
    end

    context "when an invalid picture is passed" do
      let(:invalid_picture) do
        "#{Rails.root}/spec/support/fixtures/community/user/profile_picture_that_does_not_exist.png"
      end

      it "does not change the auto_generate_profile_picture option" do
        user.options[:auto_generate_profile_picture] = "some random text"
        user.profile_picture = invalid_picture
        expect(user.options[:auto_generate_profile_picture]).to match "some random text"
      end
    end
  end

  describe "#to_param" do
    it "returns the username" do
      expect(user.to_param).to eq(user.username)
    end
  end

  describe "#to_s" do
    it "returns the username" do
      expect("#{user}").to eq(user.username)
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

  describe "#unread_private_conversations" do
    before { user.save }
    let!(:conversations) { create_list(:private_conversation, 5, :sender => user) }
    let(:unread_conversations) { user.unread_private_conversations }

    it "returns conversations in the order of most recent activity" do
      expect(unread_conversations[0].updated_at).to be > unread_conversations[1].updated_at
      expect(unread_conversations[1].updated_at).to be > unread_conversations[2].updated_at
      expect(unread_conversations[2].updated_at).to be > unread_conversations[3].updated_at
      expect(unread_conversations[3].updated_at).to be > unread_conversations[4].updated_at
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

  describe "#viewable_by?" do
    subject(:user) { create(:user)}
    let(:anonymous_user) { nil }
    let(:registered_user) { build_stubbed(:user) }
    let(:friend) { create(:friendship, initiator: user, acceptor: create(:user)).acceptor }

    context "when visibility is public" do
      before { user.public_visibility! }

      it "is viewable by anonymous users" do
        is_expected.to be_viewable_by anonymous_user
      end
      it "is viewable by registered users" do
        is_expected.to be_viewable_by registered_user
      end
      it "is viewable by friends" do
        is_expected.to be_viewable_by friend
      end
      it "is viewable by profile owner" do
        is_expected.to be_viewable_by user
      end
    end

    context "when visibility is network" do
      before { user.network_visibility! }

      it "is not viewable by anonymous users" do
        is_expected.not_to be_viewable_by anonymous_user
      end
      it "is viewable by registered users" do
        is_expected.to be_viewable_by registered_user
      end
      it "is viewable by friends" do
        is_expected.to be_viewable_by friend
      end
      it "is viewable by profile owner" do
        is_expected.to be_viewable_by user
      end
    end

    context "when visibility is private" do
      before { user.private_visibility! }

      it "is not viewable by anonymous users" do
        is_expected.not_to be_viewable_by anonymous_user
      end
      it "is not viewable by registered users" do
        is_expected.not_to be_viewable_by registered_user
      end
      it "is viewable by friends" do
        is_expected.to be_viewable_by friend
      end
      it "is viewable by profile owner" do
        is_expected.to be_viewable_by user
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

  describe "#blacklist_username" do

    it "saves the username to the blacklisted usernames" do
      user.username = "tom_and_jerry"
      user.send(:blacklist_username)
      expect(Helper::BlacklistedUsername.exists?(username: "tom_and_jerry")).to be_truthy
    end
  end

  describe "#delete_attachment_folder" do

    let!(:user) { create(:user_with_picture) }
    let(:path_to_attachment_folder) do
      "#{Rails.root}" +
      Rails.configuration.attachment_storage_location +
      "users/#{user.username}"
    end

    it "deletes the folder of attachments belonging to the user" do
      expect(Dir.exists?(path_to_attachment_folder)).to be true
      user.send(:delete_attachment_folder)
      expect(Dir.exists?(path_to_attachment_folder)).to be false
    end

  end

  describe "destroy_original_profile_picture" do

    it "removes the original profile picture" do
      expect(File).to receive(:unlink).with(user.profile_picture.path(:original))
      user.send(:destroy_original_profile_picture)
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

  describe "Profile Picture" do

    it "strips exif metadata from uploaded image" do
      image_with_exif_data = "#{Rails.root}/spec/support/fixtures/community/user/image_with_exif_data.jpg"
      exif_data = %x{identify -verbose #{image_with_exif_data}}
      expect(exif_data).to match(/exif:/)

      user.profile_picture = File.new(image_with_exif_data)
      user.save
      uploaded_image = user.profile_picture.path

      exif_data = %x{identify -verbose #{uploaded_image}}

      expect(exif_data).not_to match(/exif:/)
    end

  end

end
