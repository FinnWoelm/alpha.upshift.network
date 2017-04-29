require 'rails_helper'

RSpec.describe PostsController do

  let(:current_user) { create(:user) }
  let(:sign_user_in) { @request.session['user_id'] = current_user.id }
  let(:sign_user_out) { @request.session['user_id'] = nil }

  before { sign_user_in }

  it { is_expected.to use_before_action(:authorize) }

  describe "GET #show" do
    let!(:post) { create(:post) }
    let(:perform_action) do
      get :show, params: {
        :id => post.id
      }
    end

    it "does not use before_action: authorize" do
      expect(controller).not_to receive(:authorize)
      perform_action
    end

    it "does use before_action: current_user" do
      expect(controller).to receive(:current_user)
      perform_action
    end

    context "when user is logged in" do
      before { perform_action }

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template :show}
      it { is_expected.to render_with_layout "application"}
    end

    context "when user is not logged in" do
      before do
        sign_user_out
        post.author.public_visibility!
        post.recipient.public_visibility!
        perform_action
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template :show}
      it { is_expected.to render_with_layout "without_sidenav" }
    end

    context "when post cannot be found" do
      before do
        allow(Post).
          to receive(:readable_by_user).and_return(Post.none)
        perform_action
      end

      it { is_expected.to respond_with :not_found }
      it { is_expected.to render_template :error}
      it { is_expected.to render_with_layout "errors"}
    end

    context "@post" do

      it "applies scope: readable by current user" do
        expect(Post).to receive(:readable_by_user).with(current_user).and_return(Post.none)
        perform_action
        expect(assigns(:post)).to equal nil
      end

      it "applies scope: find_by" do
        expect(Post).to receive(:find_by_id).with(post.id).and_return(nil)
        perform_action
        expect(assigns(:post)).to equal nil
      end
    end
  end
end
