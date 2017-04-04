# require 'rails_helper.rb'
#
# feature 'Democracy::Community::Decision' do
#
#   scenario 'User can create a new decision' do
#     given_i_am_logged_in_as_a_user
#     and_there_is_a_community
#     when_i_go_to_the_decisions_of_the_community
#     and_add_a_new_decision
#     then_my_decision_should_exist
#     and_be_shown_on_the_decisions_page
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
#   def and_there_is_a_community
#     @community = create(:democracy_community)
#   end
#
#   def when_i_go_to_the_decisions_of_the_community
#     visit community_decisions_path @community
#   end
#
#   def and_add_a_new_decision
#     click_on 'New Decision'
#     @decision = build(:democracy_community_decision)
#     fill_in "Title", with: @decision.title
#     fill_in "Description", with: @decision.description
#     fill_in "Deadline for Participation", with: @decision.ends_at
#     click_on "Publish"
#   end
#
#   def then_my_decision_should_exist
#     expect(Democracy::Community::Decision.find_by_title(@decision.title)).to be_present
#   end
#
#   def and_be_shown_on_the_decisions_page
#     expect(page).to have_content(@decision.description)
#   end
#
# end
