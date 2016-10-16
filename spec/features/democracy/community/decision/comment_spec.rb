require 'rails_helper.rb'

feature 'Democracy::Community::Decision::Comment' do

  scenario 'User can add a comment' do
    given_i_am_logged_in_as_a_user
    and_there_is_a_community_with_a_decision
    when_i_go_to_the_decision
    and_add_a_new_comment
    then_the_comment_should_exist
  end

  scenario 'User can delete a comment' do
    given_i_am_logged_in_as_a_user
    and_there_is_a_community_with_a_decision
    and_a_comment_from_me
    when_i_go_to_the_decision
    and_delete_the_comment
    then_the_comment_should_not_exist
  end

  scenario 'User can like a comment' do
    given_i_am_logged_in_as_a_user
    and_there_is_a_community_with_a_decision
    and_a_comment_from_me
    when_i_go_to_the_decision
    and_like_the_comment
    then_the_comment_should_be_liked
  end

  scenario 'User can unlike a comment' do
    given_i_am_logged_in_as_a_user
    and_there_is_a_community_with_a_decision
    and_a_comment_from_me
    when_i_go_to_the_decision
    and_like_the_comment
    and_unlike_the_comment
    then_the_comment_should_not_be_liked
  end

  def given_i_am_logged_in_as_a_user
    @user = create(:user)
    visit login_path
    fill_in 'email',    with: @user.email
    fill_in 'password', with: @user.password
    click_button 'Login'
  end

  def and_there_is_a_community_with_a_decision
    @decision = create(:democracy_community_decision)
    @community = @decision.community
  end

  def and_a_comment_from_me
    @comment = create(:comment, :commentable => @decision, :author => @user)
  end

  def when_i_go_to_the_decision
    visit decision_path(@decision)
  end

  def and_add_a_new_comment
    @comment = build(:comment, :commentable => @decision)
    fill_in "comment_content", with: @comment.content
    click_on "Add Comment"
  end

  def and_delete_the_comment
    click_link "Delete Comment"
  end

  def and_like_the_comment
    click_button "LIKE"
  end

  def and_unlike_the_comment
    click_link "UNLIKE"
  end

  def then_the_comment_should_exist
    expect(@decision.comments.count).to eq 1
    expect(page).to have_content(@comment.content)
  end

  def then_the_comment_should_not_exist
    expect(@decision.comments.count).to eq 0
    expect(page).not_to have_content(@comment.content)
  end

  def then_the_comment_should_be_liked
    expect(@decision.comments.first.likes_count).to eq 1
  end

  def then_the_comment_should_not_be_liked
    expect(@decision.comments.first.likes_count).to eq 0
  end

end
