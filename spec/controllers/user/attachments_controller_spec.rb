require 'rails_helper'

RSpec.describe User::AttachmentsController, type: :controller do

  let(:current_user) { create(:user) }
  let(:sign_user_in) { @request.session['user_id'] = current_user.id }

  before { sign_user_in }

  it { is_expected.to use_before_action(:current_user) }

  describe "GET #show" do
    let(:user) { create(:user_with_picture) }
    let(:perform_action) do
      get :show, params: {
        :username => user.username,
        :attachment => "profile_picture",
        :size => "medium"
      }
    end

    it do
      perform_action
      is_expected.to respond_with :ok
    end

    it "sets max-age to 365 days" do
      perform_action
      expect(controller.response.header["Cache-Control"]).to include("max-age=#{365.days.to_i}")
    end

    it "sets cache to private" do
      perform_action
      expect(controller.response.header["Cache-Control"]).to include("private")
    end

    context "when user is not found" do
      let(:user) { build(:user) }
      before { perform_action }

      it { is_expected.to respond_with :not_found }
    end

    context "when user is not visible to current user" do
      before do
        allow_any_instance_of(User).to receive(:viewable_by?).and_return(false)
        perform_action
      end

      it { is_expected.to respond_with :not_found }
    end

    context "when attachment is nil" do
      before do
        user.profile_picture_via_paperclip = nil
        user.save
        perform_action
      end

      it { is_expected.to respond_with :not_found }
    end

  end
end
