# require 'rails_helper'
#
# RSpec.describe "democracy/community/decisions/show.html.erb", type: :view do
#
#   let(:decision) { create(:democracy_community_decision) }
#
#   before do
#     assign(:decision, decision)
#     assign(:current_user, build_stubbed(:user))
#     assign(:comment, build(:comment, :commentable => decision))
#     assign(:comments, Comment.none)
#   end
#
#   it "has a form for creating a new comment" do
#    render
#
#    expect(rendered).to have_selector("form", text: "Comment")
#   end
#
#   it "it lists comments" do
#    assign(:comments, create_list(:comment, 3, :commentable => decision))
#    render
#
#    expect(rendered).to have_selector("div.decision_comment", count: 3)
#   end
#
#   it "shows number of upvotes" do
#     decision.votes_count[:upvotes] = 6
#     render
#
#     expect(rendered).to have_selector("span.upvotes_count", text: 6)
#   end
#
#   it "shows number of downvotes" do
#     decision.votes_count[:downvotes] = 99
#     render
#
#     expect(rendered).to have_selector("span.downvotes_count", text: 99)
#   end
#
# end
