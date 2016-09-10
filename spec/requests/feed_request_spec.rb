require 'rails_helper'
include SignInHelper

RSpec.describe "Feed", type: :request do
  describe "GET #show" do

    let(:user) { create(:user) }
    before { sign_in_as( user ) }

    describe "filters" do

      it "requires authorization" do
        expect_any_instance_of(FeedsController).to receive(:authorize)
        get feed_path
      end
    end

    describe "variables" do

      describe "@posts" do
        let(:friends_and_user) do
          create_list(:friendship, 5, initiator: user)
          [user] + user.friends
        end
        let!(:posts_of_friends_and_user) do
          some_posts = []
          30.times do
            some_posts << create(:post, author: friends_and_user.sample)
          end
          some_posts.reverse
        end
        let!(:posts_of_others) { create_list(:post, 20) }
        let(:posts) { @controller.instance_variable_get(:@posts) }

        it "assigns posts of friend and user" do
          get feed_path
          expect(posts).to match(posts_of_friends_and_user)
        end

        it "does not assign posts of others" do
          get feed_path
          expect(posts).not_to match_array(posts_of_others)
        end
      end

    end

  end
end
