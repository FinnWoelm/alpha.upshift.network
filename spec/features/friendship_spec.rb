require 'rails_helper.rb'
require 'support/features/login_helper.rb'

feature 'Friendship' do

  scenario 'User ends a friendship' do
    given_i_am_logged_in_as_a_user
    and_i_have_a_friend
    when_i_visit_the_page_of_my_friend
    and_i_end_the_friendship
    then_we_should_not_be_friends
  end

  def and_i_have_a_friend
    @friend = create(:user)
    create(:friendship, :initiator => @user, :acceptor => @friend)
  end

  def when_i_visit_the_page_of_my_friend
    visit @friend
  end

  def and_i_end_the_friendship
    click_on 'End Friendship'
  end

  def then_we_should_not_be_friends
    expect(@user).not_to have_friendship_with (@friend)
    expect(@friend).not_to have_friendship_with (@user)
    expect(@user.friendship_requests_sent.size).to eq(0)
    expect(@user.friends.size).to eq(0)
  end

end
