require 'rails_helper.rb'
require 'support/features/login_helper.rb'

feature 'Feed' do

  scenario 'User sees feed after logging in' do
    given_i_am_a_user
    when_i_log_in
    then_i_should_see_my_feed
  end

  scenario 'User sees posts from their own network (friends and self)' do
    given_i_am_logged_in_as_a_user
    when_there_are_posts_from_and_to_my_network
    and_i_am_seeing_my_feed
    then_i_should_see_the_posts
  end

  scenario 'User does not see posts from friends to non-friends' do
    given_i_am_logged_in_as_a_user

    # when_there_are_posts_from_friends_to_non_friends
    create_list(:friendship, 2, initiator: @user)
    @user.friends_found.find_each {|f| create_list(:post, 3, :author => f) }

    # and_i_am_seeing_my_feed
    visit feed_path

    # then_i_should_not_see_the_posts
    @user.friends_found.find_each do |friend|
      friend.posts_made.find_each do |post|
        expect(page).not_to have_content(post.content)
      end
    end
  end

  context "When user scrolls to bottom of feed (infinity scroll)" do
    scenario 'User can see older posts', :js => true do
      given_i_am_logged_in_as_a_user

      # and there are more feed items than fit on a page
      feed_items_per_page = Rails.configuration.x.feed.items_per_page
      create_list(:post, feed_items_per_page+1, :recipient => @user)

      # when I visit my feed
      visit root_path

      # then I should see as many feed items as are shown per page
      expect(page).to have_selector(".post-wrapper:not(.post_form)", count: feed_items_per_page)

      # when I scroll to the bottom
      page.execute_script "window.scrollBy(0, $('.infinity_scroll.next').offset().top)"

      # then I should see as many feed items as are shown per page + 1
      expect(page).to have_selector(".post-wrapper:not(.post_form)", count: feed_items_per_page+1)
    end
  end

  def given_i_am_a_user
    @user = create(:user)
  end

  def when_i_log_in
    visit login_path
    fill_in 'email',    with: @user.account.email
    fill_in 'password', with: @user.account.password
    click_button 'Login'
  end

  def then_i_should_see_my_feed
    expect(page).to have_content("Feed")
  end

  def when_there_are_posts_from_and_to_my_network
    friends_and_myself = [@user]
    create_list(:friendship, 5, initiator: @user)

    friends_and_myself += @user.friends

    @posts = []

    10.times do
      @posts <<
        create(
          :post,
          :author => friends_and_myself.sample,
          :recipient => friends_and_myself.sample
        )
    end
  end

  def and_i_am_seeing_my_feed
    # root_path = feed_path
    visit root_path
  end

  def then_i_should_see_the_posts
    @posts.each do |post|
      expect(page).to have_content(post.content)
    end
  end


end
