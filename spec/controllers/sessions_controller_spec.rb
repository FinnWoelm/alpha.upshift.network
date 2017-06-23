require 'rails_helper'

RSpec.describe SessionsController, type: :controller do

  let(:current_user) { create(:user) }
  let(:sign_user_in) { @request.session['user_id'] = current_user.id }

  describe "GET #new" do
    let(:perform_action) { get :new }

    context "when action is performed" do
      before { perform_action }

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template :new }
      it { is_expected.to render_with_layout "without_sidenav" }
    end

    context "when user is logged in" do
      before do
        sign_user_in
        perform_action
      end

      it "sets the session to nil" do
        expect(@request.session['user_id']).to be nil
      end
    end

  end
end
