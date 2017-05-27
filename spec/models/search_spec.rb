require 'rails_helper'

RSpec.describe Search, type: :model do

  describe ".find_users_by_name" do

    context "when searching for 'ian'" do
      let!(:matches) do
        [
          create(:public_user, :name => "ian"), # exact match
          create(:public_user, :name => "ian 2"), # word match start
          create(:public_user, :name => "the ian"), # word match end
          create(:public_user, :name => "i am ian 2"), # word match middle
          create(:public_user, :name => "ianston"), # partial match start
          create(:public_user, :name => "brian"), # partial match end
          create(:public_user, :name => "imiano") # partial match middle
        ]
      end
      let!(:non_matches) do
        [
          create(:public_user, :name => "alice"),
          create(:public_user, :name => "carla"),
          create(:public_user, :name => "dennis"),
        ]
      end

      it "finds users that match the query 'ian'" do
        expect(Search.find_users_by_name('ian')).to match_array matches
      end

      it "does not find users not matching the query 'ian'" do
        records = Search.find_users_by_name('ian')
        non_matches.each do |non_match|
          expect(records).not_to include non_match
        end
      end

      it "correctly weights matches" do
        expect(Search.find_users_by_name('ian').to_a).to eq matches
      end
    end

    context "when query includes %" do
      let!(:amp_user) { create(:public_user, :name => "My % name")}
      let!(:non_amp_user) { create(:public_user, :name => "User without amp")}

      it "finds users with % in their name" do
         expect(Search.find_users_by_name("%")).to include amp_user
      end

      it "does not find users without % in their name" do
         expect(Search.find_users_by_name("%")).not_to include non_amp_user
      end
    end

    context "when name includes accents" do
      let!(:user_with_accent) { create(:public_user, :name => "Gørún Björn")}

      it "finds the user regardless" do
        expect(Search.find_users_by_name("Gorun Bjorn")).to include user_with_accent
      end
    end

    context "when query includes _" do
      let!(:underscore_user) { create(:public_user, :name => "My _ name", :username => "my___name")}
      let!(:non_underscore_user) { create(:public_user, :name => "User without underscore")}

      it "finds users with _ in their name" do
         expect(Search.find_users_by_name("_")).to include underscore_user
      end

      it "does not find users without _ in their name" do
         expect(Search.find_users_by_name("_")).not_to include non_underscore_user
      end
    end

    context "when search query is two or more words" do
      let!(:match_one) { create(:public_user, :name => "Alice Match")}
      let!(:match_two) { create(:public_user, :name => "Alice This Will Match")}
      let!(:non_match) { create(:public_user, :name => "Alice This Will NotMatch")}

      it "finds names that have non-matching words in between" do
        expect(Search.find_users_by_name("Alice Match")).to include match_one
        expect(Search.find_users_by_name("Alice Match")).to include match_two
        expect(Search.find_users_by_name("Alice Match")).not_to include non_match
      end
    end

    context "when two results are weighted the same" do
      let!(:long_match) { create(:public_user, :name => "ian_match_long")}
      let!(:short_match) { create(:public_user, :name => "ian_match")}
      let(:records) { Search.find_users_by_name("ian").to_a }

      it "returns the shorter one first" do
        expect(records.index(short_match)).to be < records.index(long_match)
      end
    end

    context "when user argument is passed" do
      let!(:user) { create(:user) }
      let!(:public_users) { create_list(:public_user, 3) }
      let!(:network_users) { create_list(:network_user, 3) }
      let!(:friends) do
        create_list(:friendship, 3, :initiator => user)
        user.friends.each {|friend| friend.private_visibility! }
        user.friends
      end
      let!(:private_users) { create_list(:private_user, 3) }
      let(:records) { Search.find_users_by_name("", user).to_a }

      it "can find public users" do
        public_users.each do |user|
          expect(records).to include user
        end
      end

      it "can find network users" do
        network_users.each do |user|
          expect(records).to include user
        end
      end

      it "can find private users who are friends" do
        friends.each do |user|
          expect(records).to include user
        end
      end

      it "cannot find private users who are not friends" do
        private_users.each do |user|
          expect(records).not_to include user
        end
      end
    end

    context "when user argument is nil" do
      let!(:user) { nil }
      let!(:public_users) { create_list(:public_user, 3) }
      let!(:network_users) { create_list(:network_user, 3) }
      let!(:private_users) { create_list(:private_user, 3) }
      let(:records) { Search.find_users_by_name("", user).to_a }

      it "can find public users" do
        public_users.each do |user|
          expect(records).to include user
        end
      end

      it "cannot find network users" do
        network_users.each do |user|
          expect(records).not_to include user
        end
      end

      it "cannot find private users who are not friends" do
        private_users.each do |user|
          expect(records).not_to include user
        end
      end
    end
  end

  describe ".find_users_by_username" do

    context "when searching for 'ian'" do
      let!(:matches) do
        [
          create(:public_user, :username => "ian"), # exact match
          create(:public_user, :username => "ian_2"), # word match start
          create(:public_user, :username => "the_ian"), # word match end
          create(:public_user, :username => "i_am_ian_2"), # word match middle
          create(:public_user, :username => "ianston"), # partial match start
          create(:public_user, :username => "brian"), # partial match end
          create(:public_user, :username => "imiano") # partial match middle
        ]
      end
      let!(:non_matches) do
        [
          create(:public_user, :username => "alice"),
          create(:public_user, :username => "carla"),
          create(:public_user, :username => "dennis"),
        ]
      end

      it "finds users that match the query 'ian'" do
        expect(Search.find_users_by_username('ian')).to match_array matches
      end

      it "does not find users not matching the query 'ian'" do
        records = Search.find_users_by_username('ian')
        non_matches.each do |non_match|
          expect(records).not_to include non_match
        end
      end

      it "correctly weights matches" do
        expect(Search.find_users_by_username('ian').to_a).to eq matches
      end
    end

    context "when query includes _" do
      let!(:underscore_user) { create(:public_user, :username => "my_name")}
      let!(:non_underscore_user) { create(:public_user, :username => "myname")}

      it "finds users with _ in their name" do
         expect(Search.find_users_by_username("_")).to include underscore_user
      end

      it "does not find users without _ in their name" do
         expect(Search.find_users_by_username("_")).not_to include non_underscore_user
      end
    end

    context "when two results are weighted the same" do
      let!(:long_match) { create(:public_user, :username => "ian_match_long")}
      let!(:short_match) { create(:public_user, :username => "ian_match")}
      let(:records) { Search.find_users_by_username("ian").to_a }

      it "returns the shorter one first" do
        expect(records.index(short_match)).to be < records.index(long_match)
      end
    end

    context "when user argument is passed" do
      let!(:user) { create(:user) }
      let!(:public_users) { create_list(:public_user, 3) }
      let!(:network_users) { create_list(:network_user, 3) }
      let!(:friends) do
        create_list(:friendship, 3, :initiator => user)
        user.friends.each {|friend| friend.private_visibility! }
        user.friends
      end
      let!(:private_users) { create_list(:private_user, 3) }
      let(:records) { Search.find_users_by_username("", user).to_a }

      it "can find public users" do
        public_users.each do |user|
          expect(records).to include user
        end
      end

      it "can find network users" do
        network_users.each do |user|
          expect(records).to include user
        end
      end

      it "can find private users who are friends" do
        friends.each do |user|
          expect(records).to include user
        end
      end

      it "cannot find private users who are not friends" do
        private_users.each do |user|
          expect(records).not_to include user
        end
      end
    end

    context "when user argument is nil" do
      let!(:user) { nil }
      let!(:public_users) { create_list(:public_user, 3) }
      let!(:network_users) { create_list(:network_user, 3) }
      let!(:private_users) { create_list(:private_user, 3) }
      let(:records) { Search.find_users_by_username("", user).to_a }

      it "can find public users" do
        public_users.each do |user|
          expect(records).to include user
        end
      end

      it "cannot find network users" do
        network_users.each do |user|
          expect(records).not_to include user
        end
      end

      it "cannot find private users who are not friends" do
        private_users.each do |user|
          expect(records).not_to include user
        end
      end
    end
  end

  describe ".find_users_by_username_and_name" do
    context "when searching for 'ian'" do
      let!(:matches) do
        [
          create(:public_user, :username => "ian", :name => "Ignore Me 0"), # exact match
          create(:public_user, :username => "ignore_me_0", :name => "Ian"), # exact match
          create(:public_user, :username => "ian_2", :name => "Ignore Me 1"), # word match start
          create(:public_user, :username => "ignore_me_1", :name => "Ian 2"), # word match start
          create(:public_user, :username => "the_ian", :name => "Ignore Me 2"), # word match end
          create(:public_user, :username => "ignore_me_2", :name => "the ian"), # word match end
          create(:public_user, :username => "i_am_ian_2", :name => "Ignore Me 3"), # word match middle
          create(:public_user, :username => "ignore_me_3", :name => "i am ian 2"), # word match middle
          create(:public_user, :username => "ianston", :name => "Ignore Me 4"), # partial match start
          create(:public_user, :username => "ignore_me_4", :name => "ianston"), # partial match start
          create(:public_user, :username => "brian", :name => "Ignore Me 5"), # partial match end
          create(:public_user, :username => "ignore_me_5", :name => "Brian"), # partial match end
          create(:public_user, :username => "imiano", :name => "Ignore Me 6"), # partial match middle
          create(:public_user, :username => "ignore_me_6", :name => "imiano") # partial match middle
        ]
      end
      let!(:non_matches) do
        [
          create(:public_user, :username => "alice", :name => "Alice"),
          create(:public_user, :username => "carla", :name => "Carla"),
          create(:public_user, :username => "dennis", :name => "Dennis"),
        ]
      end

      it "finds users that match the query 'ian'" do
        expect(Search.find_users_by_username_and_name('ian')).to match_array matches
      end

      it "does not find users not matching the query 'ian'" do
        records = Search.find_users_by_username_and_name('ian')
        non_matches.each do |non_match|
          expect(records).not_to include non_match
        end
      end

      it "correctly weights matches" do
        expect(Search.find_users_by_username_and_name('ian').to_a).to eq matches
      end
    end

    context "when name includes accents" do
      let!(:user_with_accent) { create(:public_user, :name => "Gørún Björn", :username => "ignore_me")}

      it "finds the user regardless" do
        expect(Search.find_users_by_username_and_name("Gorun Bjorn")).to include user_with_accent
      end
    end

    context "when query includes %" do
      let!(:amp_user) { create(:public_user, :name => "My % name")}
      let!(:non_amp_user) { create(:public_user, :name => "User without amp")}

      it "finds users with % in their name" do
         expect(Search.find_users_by_username_and_name("%")).to include amp_user
      end

      it "does not find users without % in their name" do
         expect(Search.find_users_by_username_and_name("%")).not_to include non_amp_user
      end
    end

    context "when query includes _" do
      let!(:underscore_user) { create(:public_user, :name => "My _ name", :username => "my___name")}
      let!(:non_underscore_user) { create(:public_user, :name => "User without underscore", :username => "myname")}

      it "finds users with _ in their name" do
         expect(Search.find_users_by_username_and_name("_")).to include underscore_user
      end

      it "does not find users without _ in their name" do
         expect(Search.find_users_by_username_and_name("_")).not_to include non_underscore_user
      end
    end

    context "when search query is two or more words" do
      let!(:match_one) { create(:public_user, :name => "Alice Match")}
      let!(:match_two) { create(:public_user, :name => "Alice This Will Match")}
      let!(:non_match) { create(:public_user, :name => "Alice This Will NotMatch")}

      it "finds names that have non-matching words in between" do
        expect(Search.find_users_by_username_and_name("Alice Match")).to include match_one
        expect(Search.find_users_by_username_and_name("Alice Match")).to include match_two
        expect(Search.find_users_by_username_and_name("Alice Match")).not_to include non_match
      end
    end

    context "when two results are weighted the same" do
      let!(:long_match) { create(:public_user, :name => "ian_match_long")}
      let!(:short_match) { create(:public_user, :name => "ian_match")}
      let(:records) { Search.find_users_by_username_and_name("ian").to_a }

      it "returns the shorter one first" do
        expect(records.index(short_match)).to be < records.index(long_match)
      end
    end

    context "when user argument is passed" do
      let!(:user) { create(:user) }
      let!(:public_users) { create_list(:public_user, 3) }
      let!(:network_users) { create_list(:network_user, 3) }
      let!(:friends) do
        create_list(:friendship, 3, :initiator => user)
        user.friends.each {|friend| friend.private_visibility! }
        user.friends
      end
      let!(:private_users) { create_list(:private_user, 3) }
      let(:records) { Search.find_users_by_username_and_name("", user).to_a }

      it "can find public users" do
        public_users.each do |user|
          expect(records).to include user
        end
      end

      it "can find network users" do
        network_users.each do |user|
          expect(records).to include user
        end
      end

      it "can find private users who are friends" do
        friends.each do |user|
          expect(records).to include user
        end
      end

      it "cannot find private users who are not friends" do
        private_users.each do |user|
          expect(records).not_to include user
        end
      end
    end

    context "when user argument is nil" do
      let!(:user) { nil }
      let!(:public_users) { create_list(:public_user, 3) }
      let!(:network_users) { create_list(:network_user, 3) }
      let!(:private_users) { create_list(:private_user, 3) }
      let(:records) { Search.find_users_by_username_and_name("", user).to_a }

      it "can find public users" do
        public_users.each do |user|
          expect(records).to include user
        end
      end

      it "cannot find network users" do
        network_users.each do |user|
          expect(records).not_to include user
        end
      end

      it "cannot find private users who are not friends" do
        private_users.each do |user|
          expect(records).not_to include user
        end
      end
    end
  end
end
