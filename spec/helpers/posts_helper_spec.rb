require 'rails_helper'

RSpec.describe PostsHelper, type: :helper do

  describe "#write_comment_for_post_action" do
    subject(:write_comment_for_post_action) { helper.write_comment_for_post_action }
    let(:post) { create(:post) }
    after { helper.write_comment_for_post_action(post) }

    context "when user is not signed in" do
      before { @current_user = nil }

      it "does not render partial" do
        expect(helper).not_to receive(:render)
      end
    end

    context "when user is signed in" do
      before { @current_user = post.author }

      context "when comment is undefined" do
        before { @comment = nil }

        it "renders partial with new comment" do
          expect(helper).to receive(:render).with(
            :partial => "comments/form",
            :locals  => { :comment => instance_of(Comment) }
          )
        end
      end

      context "when comment is defined" do
        before { @comment = class_double(Comment) }

        it "renders partial with new comment" do
          expect(helper).to receive(:render).with(
            :partial => "comments/form",
            :locals  => { :comment => @comment }
          )
        end
      end

    end

  end

end
