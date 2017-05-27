require 'rails_helper'

RSpec.describe SearchController, type: :controller do

  let(:current_user) { create(:user) }
  let(:sign_user_in) { @request.session['user_id'] = current_user.id }
  let(:sign_user_out) { @request.session['user_id'] = nil }

  it { is_expected.to use_before_action(:current_user) }

  describe "GET #search" do
    let(:query) { "Alice" }
    let(:perform_action) do
      get :search, params: {
        :query => query
      }
    end

    it "sets @search_query to the query" do
      perform_action
      expect(assigns(:search_query)).to eq query
    end

    context "when user is logged in" do
      before do
        sign_user_in
        perform_action
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template :search }
      it { is_expected.to render_with_layout "application" }
    end

    context "when user is not logged in" do
      before do
        sign_user_out
        perform_action
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template :search }
      it { is_expected.to render_with_layout "without_sidenav" }
    end

    context "when query is not present" do
      let(:query) { "" }

      it "sets results to none" do
        perform_action
        expect(assigns(:results)).to eq User.none
      end
    end

    context "when query starts with @" do
      let(:query) { "@username" }

      it "finds users by username" do
        expect(Search).to receive(:find_users_by_username) { User.none }
        perform_action
      end
    end

    context "when query starts with \"" do
      let(:query) { "\"Alice" }

      it "finds users by name" do
        expect(Search).to receive(:find_users_by_name) { User.none }
        perform_action
      end
    end

    context "when query does not match username format" do
      let(:query) { "Search Query" }

      it "finds users by name" do
        expect(Search).to receive(:find_users_by_name) { User.none }
        perform_action
      end
    end

    context "when query matches username format" do
      let(:query) { "search_query" }

      it "finds users by username and name" do
        expect(Search).to receive(:find_users_by_username_and_name) { User.none }
        perform_action
      end
    end

  end
end
