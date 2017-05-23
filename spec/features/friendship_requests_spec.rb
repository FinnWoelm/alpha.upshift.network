require 'rails_helper.rb'
require 'support/features/login_helper.rb'

feature 'Friendship Request' do

  scenario 'User sends a friend request' do
    given_i_am_logged_in_as_a_user
    when_i_visit_the_page_of_another_user
    and_i_send_a_friend_request
    then_another_user_should_have_received_a_friend_request
  end

  scenario 'User can send a friend request to a user with private visibility' do
    given_i_am_logged_in_as_a_user

    # and there is a private user
    @private_user = create(:user, :visibility => :private)

    # when I go to my friend requests
    visit friendship_requests_path

    # and I fill in the private user's username
    fill_in "Add friend...", with: "@#{@private_user.username}"
    click_on "Add friend"

    # then I should see a success message
    expect(page).to have_content "Friend request sent to @#{@private_user.username}"

    # and private user should have received my request
    expect(
      FriendshipRequest.exists?(:sender => @user, :recipient => @private_user)
      ).to be_truthy
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

  context "When user scrolls to bottom of requests (infinity scroll)" do
    scenario 'User can see older requests', :js => true do
      given_i_am_logged_in_as_a_user

      # and there are more friendship requests than fit on a page
      create_list(:friendship_request, FriendshipRequest.per_page+1, :recipient => @user)

      # when I visit my friendship requests
      visit friendship_requests_path

      # then I should see as many friendship requests as are shown per page
      expect(page).to have_selector(".friendship_request", count: FriendshipRequest.per_page)

      # when I scroll to the bottom
      page.driver.scroll_to(0, 10000)

      # then I should see as many friendship requests as are shown per page + 1
      expect(page).to have_selector(".friendship_request", count: FriendshipRequest.per_page+1)
    end
  end

  def when_i_visit_the_page_of_another_user
    @another_user = create(:user)
    visit @another_user
  end

  def and_i_send_a_friend_request
    click_button 'Add Friend'
  end

  def then_another_user_should_have_received_a_friend_request
    expect(@another_user.friendship_requests_received.size).to eq(1)
  end

  def when_i_receive_some_friend_requests
    5.times { create(:friendship_request, :recipient => @user) }
  end

  def and_visit_my_friend_requests_page
    visit friendship_requests_path
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
    visit friendship_requests_path
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
    visit friendship_requests_path
    click_on 'Reject'
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
    click_on "Cancel Friend Request"
  end

end
