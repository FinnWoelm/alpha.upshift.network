require 'rails_helper.rb'

feature 'Friendship Request' do

  scenario 'User sends a friend request' do
    given_i_am_logged_in_as_a_user
    when_i_visit_the_page_of_another_user
    and_i_send_a_friend_request
    then_another_user_should_have_received_a_friend_request
  end

  scenario 'User views friend requests' do
    given_i_am_logged_in_as_a_user
    when_i_receive_some_friend_requests
    and_visit_my_friend_requests_page
    then_i_should_see_some_friend_requests
  end

  scenario 'User accepts a friend request' do
    given_i_am_logged_in_as_a_user
    when_i_receive_a_friend_request
    and_accept_the_friend_request
    then_we_should_both_be_friends
  end

  scenario 'User rejects a friend request' do
    given_i_am_logged_in_as_a_user
    when_i_receive_a_friend_request
    and_reject_the_friend_request
    then_we_should_not_be_friends
  end

  scenario 'User revokes a friend request' do
    given_i_am_logged_in_as_a_user
    when_i_visit_the_page_of_another_user
    and_i_send_a_friend_request
    and_revoke_the_friend_request
    then_we_should_not_be_friends
  end

  def given_i_am_logged_in_as_a_user
    @user = create(:user)
    visit login_path
    fill_in 'email',    with: @user.email
    fill_in 'password', with: @user.password
    click_button 'Login'
  end

  def when_i_visit_the_page_of_another_user
    @another_user = create(:user)
    visit profile_path @another_user.username
  end

  def and_i_send_a_friend_request
    click_button 'Send Friend Request'
  end

  def then_another_user_should_have_received_a_friend_request
    expect(@another_user.friendship_requests_received.size).to eq(1)
  end

  def when_i_receive_some_friend_requests
    5.times { create(:friendship_request, :recipient => @user) }
  end

  def and_visit_my_friend_requests_page
    visit friendship_requests_received_path
  end

  def then_i_should_see_some_friend_requests
    expect(@user.friendship_requests_received.size).to eq(5)
    expect(page).to have_content(@user.friendship_requests_received.first.sender.name)
  end

  def when_i_receive_a_friend_request
    request = create(:friendship_request, :recipient => @user)
    @another_user = request.sender
  end

  def and_accept_the_friend_request
    visit friendship_requests_received_path
    click_button 'Accept'
    @user.reload
    @another_user.reload
  end

  def then_we_should_both_be_friends
    expect(@user).to have_friendship_with (@another_user)
    expect(@another_user).to have_friendship_with (@user)
    expect(@user.friendship_requests_sent.size).to eq(0)
    expect(@user.friends.size).to eq(1)
  end

  def and_reject_the_friend_request
    visit friendship_requests_received_path
    click_link 'Reject'
    @user.reload
    @another_user.reload
  end

  def then_we_should_not_be_friends
    expect(@user).not_to have_friendship_with (@another_user)
    expect(@another_user).not_to have_friendship_with (@user)
    expect(@user.friendship_requests_sent.size).to eq(0)
    expect(@user.friends.size).to eq(0)
  end

  def and_revoke_the_friend_request
    click_link "Revoke Request"
  end

end
