require 'rails_helper'

RSpec.describe UsersController do

  let(:current_user) { create(:user) }
  let(:sign_user_in) { @request.session['user_id'] = current_user.id }
  let(:sign_user_out) { @request.session['user_id'] = nil }

  before { sign_user_in }

  it { is_expected.to use_before_action(:authorize) }

  describe "GET #show" do
    let(:user) { create(:user) }
    let(:perform_action) do
      get :show, params: { :username => user.username }
    end

    it "does not use before_action: authorize" do
      expect(controller).not_to receive(:authorize)
      perform_action
    end

    it "does use before_action: current_user" do
      expect(controller).to receive(:current_user)
      perform_action
    end

    context "when user can be found" do
      before { perform_action }

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template :show}
      it { is_expected.to render_with_layout "without_sidenav"}
    end

    context "when user cannot be found" do
      before do
        allow(User).
          to receive(:viewable_by_user).and_return(User.none)
        perform_action
      end

      it { is_expected.to respond_with :not_found }
      it { is_expected.to render_template :error}
      it { is_expected.to render_with_layout "errors"}
    end

    context "@user" do

      it "applies scope: viewable by current user" do
        expect(User).to receive(:viewable_by_user).with(current_user).and_return(User.none)
        perform_action
        expect(assigns(:user)).to equal nil
      end

      it "applies scope: find_by_username" do
        expect(User).to receive(:find_by_username).with(user.username).and_return(nil)
        perform_action
        expect(assigns(:user)).to equal nil
      end
    end

    context "@posts" do
      before { perform_action}

      it "applies scope: made and received by user and readable by current user" do
        expect(assigns(:posts)).
          to apply_scope(
            Post.
            made_and_received_by_user(user).
            readable_by_user(current_user)
          )
      end

      it "applies scope: most recent first" do
        expect(assigns(:posts)).
          to apply_scope(
            Post.
            most_recent_first
          )
      end
    end

    context "@post" do
      before { perform_action }

      it "builds a new post" do
        expect(assigns(:post)).to be_a_new(Post)
      end

      it "sets recipient to user being visited" do
        expect(assigns(:post).recipient).to eq user
      end
    end

    context "@color_scheme" do
      before { perform_action }

      it "sets it according to user's color scheme" do
        expect(assigns(:color_scheme)).to eq user.color_scheme
      end
    end
  end
end
