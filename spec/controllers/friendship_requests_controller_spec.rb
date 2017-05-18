require 'rails_helper'

RSpec.describe FriendshipRequestsController do

  let(:current_user) { create(:user) }
  let(:sign_user_in) { @request.session['user_id'] = current_user.id }

  before { sign_user_in }

  it { is_expected.to use_before_action(:authorize) }

  describe "POST #create" do
    let(:recipient) { create(:user) }
    let(:recipient_username) { recipient.username }
    let(:perform_action) do
      post :create, params: {
        :friendship_request => {
          :recipient_username => recipient_username
        }
      }
    end

    context "when recipient has network visibility" do
      before do
        recipient.network_visibility!
        perform_action
      end

      it { is_expected.to respond_with :redirect }
      it { is_expected.to redirect_to user_path(recipient)}
    end

    context "when recipient has private visibility" do
      before do
        recipient.private_visibility!
        perform_action
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template :index}
      it { is_expected.to render_with_layout "application"}
      it "sets success to true" do
        expect(assigns(:success)).to eq true
      end
      it "sets user_added to recipient's username" do
        expect(assigns(:user_added)).to eq recipient_username
      end
      it "overrides @friendship_request" do
        expect(assigns(:friendship_request)).to eq nil
      end
    end

    context "when recipient does not exist" do
      let(:recipient_username) { "some_random_non_existent_user" }
      before { perform_action }

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template :index}
      it { is_expected.to render_with_layout "application"}
      it "sets success to true" do
        expect(assigns(:success)).to eq true
      end
      it "sets user_added to recipient's username" do
        expect(assigns(:user_added)).to eq recipient_username
      end
      it "sets @friendship_request to nil" do
        expect(assigns(:friendship_request)).to eq nil
      end
    end

    context "when recipient_username has errors" do
      before do
        allow_any_instance_of(FriendshipRequest).to receive(:errors).and_return({
          :recipient_username => ["many errors!"]
        })
        allow_any_instance_of(Hash).to receive(:clear)
        perform_action
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template :index}
      it { is_expected.to render_with_layout "application"}
      it "does not assign @success" do
        expect(assigns(:success)).to eq nil
      end
      it "does not overrides @friendship_request" do
        expect(assigns(:friendship_request)).not_to eq nil
      end
    end

  end
end
