require 'rails_helper'

RSpec.describe PrivateConversationsController, type: :controller do

  let(:current_user) { create(:user) }
  before { @request.session['user_id'] = current_user.id }

  it { should use_before_action(:authorize) }

  describe "GET #new" do
    before { :get }
    it { expect(response).to be_success }
  end

  describe "POST #create" do
    let(:recipient) { create(:user) }
    let(:message) { attributes_for(:private_message)[:content] }
    let(:perform_request) {
      post :create, params: {
        :private_conversation => {
          recipient: recipient.username,
          :messages => {content: message}
    }}}

    context "when conversation between participants does not exist" do
      before { PrivateConversation.delete_all }

      it "creates a new conversation" do
        expect{ perform_request }.
          to change(PrivateConversation, :count).from(0).to(1)
      end

      it "creates a new message" do
        expect{ perform_request }.
          to change(PrivateMessage, :count).by(1)
      end

      it "redirects to new conversation" do
        perform_request
        is_expected.to redirect_to(assigns(:private_conversation))
      end

      context "when saving fails" do
        before { allow_any_instance_of(PrivateConversation).to receive(:save).and_return(false)}
        before { perform_request }

        it { is_expected.to render_template :new}
      end
    end

    context "when conversation between participants does exist" do
      let!(:existing_conversation) do
        create(:private_conversation, sender: current_user, recipient: recipient)
      end

      it "does not create a new conversation" do
        expect{ perform_request }.
          not_to change(PrivateConversation, :count)
      end

      it "creates a new message" do
        expect{ perform_request }.
          to change(PrivateMessage, :count).by(1)
      end

      it "redirects to existing conversation" do
        perform_request
        is_expected.to redirect_to(existing_conversation)
      end

      context "when saving fails" do
        before { allow_any_instance_of(PrivateConversation).to receive(:save).and_return(false)}
        before { perform_request }

        it { is_expected.to render_template :show}
      end

    end


  end

  describe "GET #show" do
    let!(:private_conversation) {
      create(:private_conversation, recipient: current_user, sender: sender)}
    let(:sender) { create(:user) }
    let(:perform_request) { get :show, params: {id: private_conversation.id} }

    it "marks conversation as read" do
      expect{ perform_request }.
        to change(current_user.unread_private_conversations, :count).by(-1)
    end
  end

  describe "POST #update" do
    let!(:private_conversation) {
      create(:private_conversation, sender: current_user, recipient: recipient)}
    let(:recipient) { create(:user) }
    let(:message) { attributes_for(:private_message)[:content] }
    let(:perform_request) {
      patch :update, params: {
        id: private_conversation.id,
        :private_conversation => {
          recipient: recipient.username,
          messages: {content: message}
    }}}

    context "when conversation between participants does exist" do

      it "does not create a new conversation" do
        expect{ perform_request }.
          not_to change(PrivateConversation, :count)
      end

      it "creates a new message" do
        expect{ perform_request }.
          to change(PrivateMessage, :count).by(1)
      end

      it "redirects to existing conversation" do
        perform_request
        is_expected.to redirect_to(assigns(:private_conversation))
      end

      context "when saving fails" do
        before { allow_any_instance_of(PrivateConversation).to receive(:save).and_return(false)}
        before { perform_request }

        it { is_expected.to render_template :show}
      end

    end

    context "when conversation between participants does not exist" do
      before { PrivateConversation.destroy_all }

      it "creates a new conversation" do
        expect{ perform_request }.
          to change(PrivateConversation, :count).from(0).to(1)
      end

      it "creates a new message" do
        expect{ perform_request }.
          to change(PrivateMessage, :count).by(1)
      end

      it "redirects to new conversation" do
        perform_request
        is_expected.to redirect_to(assigns(:private_conversation))
      end

      context "when saving fails" do
        before { allow_any_instance_of(PrivateConversation).to receive(:save).and_return(false)}
        before { perform_request }

        it { is_expected.to render_template :new}
      end
    end

  end

end
