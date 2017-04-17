require 'rails_helper'

RSpec.describe FeedsController do

  let(:current_user) { create(:user) }
  let(:sign_user_in) { @request.session['user_id'] = current_user.id }

  before { sign_user_in }

  it { is_expected.to use_before_action(:authorize) }

  describe "GET #show" do

    let(:perform_action) { get :show }

    context "@posts" do
      before { perform_action}

      it "applies scope: from and to network of current user" do
        expect(assigns(:posts)).
          to apply_scope(
            Post.
            from_and_to_network_of_user(current_user)
          )
      end

      it "applies scope: most recent first" do
        expect(assigns(:posts)).
          to apply_scope(
            Post.
            most_recent_first
          )
      end

      it "applies scope: limit(30)" do
        expect(assigns(:posts)).
          to apply_scope(
            Post.
            limit(30)
          )
      end
    end

    context "@post" do
      before { perform_action }

      it "builds a new post" do
        expect(assigns(:post)).to be_a_new(Post)
      end

      it "sets profile owner to current_user" do
        expect(assigns(:post).profile_owner).to eq current_user
      end
    end

  end
end
