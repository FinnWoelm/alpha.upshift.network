# require 'rails_helper.rb'
#
# feature 'Democracy::Community::Decision::Comment' do
#
#   scenario 'User can upvote' do
#     given_i_am_logged_in_as_a_user
#     and_there_is_a_community_with_a_decision
#     when_i_go_to_the_decision
#     and_upvote_the_decision
#     then_the_decision_should_be_upvoted
#   end
#
#   scenario 'User can downvote' do
#     given_i_am_logged_in_as_a_user
#     and_there_is_a_community_with_a_decision
#     when_i_go_to_the_decision
#     and_downvote_the_decision
#     then_the_decision_should_be_downvoted
#   end
#
#   scenario 'User can un-upvote' do
#     given_i_am_logged_in_as_a_user
#     and_there_is_a_community_with_a_decision
#     when_i_go_to_the_decision
#     and_upvote_the_decision
#     and_un_upvote_the_decision
#     then_the_decision_should_not_be_upvoted
#   end
#
#   scenario 'User can un-downvote' do
#     given_i_am_logged_in_as_a_user
#     and_there_is_a_community_with_a_decision
#     when_i_go_to_the_decision
#     and_downvote_the_decision
#     and_un_downvote_the_decision
#     then_the_decision_should_not_be_downvoted
#   end
#
#   scenario 'User can change from upvote to downvote' do
#     given_i_am_logged_in_as_a_user
#     and_there_is_a_community_with_a_decision
#     when_i_go_to_the_decision
#     and_upvote_the_decision
#     and_downvote_the_decision
#     then_the_decision_should_be_downvoted
#   end
#
#   scenario 'User can change from downvote to upvote' do
#     given_i_am_logged_in_as_a_user
#     and_there_is_a_community_with_a_decision
#     when_i_go_to_the_decision
#     and_downvote_the_decision
#     and_upvote_the_decision
#     then_the_decision_should_be_upvoted
#   end
#
#   def given_i_am_logged_in_as_a_user
#     @user = create(:user)
#     visit login_path
#     fill_in 'email',    with: @user.email
#     fill_in 'password', with: @user.password
#     click_button 'Login'
#   end
#
#   def and_there_is_a_community_with_a_decision
#     @decision = create(:democracy_community_decision)
#     @community = @decision.community
#   end
#
#   def when_i_go_to_the_decision
#     visit decision_path(@decision)
#   end
#
#   def and_upvote_the_decision
#     click_button "thumb_up"
#   end
#
#   def and_downvote_the_decision
#     click_button "thumb_down"
#   end
#
#   def and_un_upvote_the_decision
#     click_link "thumb_up"
#   end
#
#   def and_un_downvote_the_decision
#     click_link "thumb_down"
#   end
#
#   def then_the_decision_should_be_upvoted
#     @decision.reload
#     expect(@decision.votes_count[:total]).to eq 1
#     expect(@decision.votes_count[:upvotes]).to eq 1
#   end
#
#   def then_the_decision_should_be_downvoted
#     @decision.reload
#     expect(@decision.votes_count[:total]).to eq 1
#     expect(@decision.votes_count[:downvotes]).to eq 1
#   end
#
#   def then_the_decision_should_not_be_upvoted
#     @decision.reload
#     expect(@decision.votes_count[:total]).to eq 0
#     expect(@decision.votes_count[:upvotes]).to eq 0
#   end
#
#   def then_the_decision_should_not_be_downvoted
#     @decision.reload
#     expect(@decision.votes_count[:upvotes]).to eq 0
#     expect(@decision.votes_count[:downvotes]).to eq 0
#   end
#
#
# end
