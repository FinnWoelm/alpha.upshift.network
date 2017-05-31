require 'rails_helper.rb'
require 'support/features/login_helper.rb'

feature 'Notification' do

  scenario 'User can see notifications' do
    given_i_am_logged_in_as_a_user

    # and I have received 3 posts
    @posts = create_list(:post, 3, :recipient => @user)

    # and I have received many comments on those posts
    @comments = []
    @posts.each do |post|
      @comments << create_list(:comment, 3, :commentable => post)
    end

    # and I have received many likes on those posts
    @likes = []
    @posts.each do |post|
      @likes << create_list(:like, 3, :likable => post)
    end

    # and I have received 5 friend requests
    @requests = create_list(:friendship_request, 5, :recipient => @user)

    # when I visit my notifications
    visit notifications_path

    # then I should see 3 notifications about posts
    expect(page).to have_content("posted on your profile", count: @posts.count)

    # and I should see 3 notifications about comments
    expect(page).to have_content("commented on a post on your profile", count: @posts.count)

    # and I should see 3 notifications about likes
    expect(page).to have_content("liked a post on your profile", count: @posts.count)

    # and I should see one notification about friend requests
    expect(page).to have_content("sent you a friend request", count: 1)
  end

  scenario "Users can mark a notification as seen" do
    given_i_am_logged_in_as_a_user

    # and I have received a post
    create(:post, :recipient => @user)

    # when I visit my notifications
    visit notifications_path

    # and mark the notification as seen
    click_button 'Mark seen'

    # then I should not have unread notifications
    expect(page).to have_selector("div.notification.seen", count: 1)
    expect(page).not_to have_selector("div.notification.unseen")
  end

  scenario "Users can mark all notification as seen" do
    given_i_am_logged_in_as_a_user

    # and I have received a post plus a like and comment on the post
    create(:post, :recipient => @user)

    # when I visit my notifications
    visit notifications_path

    # and mark all notification as seen
    click_button "Mark all notifications as 'seen'"

    # then I should not have unread notifications
    expect(page).to have_selector("div.notification.seen", count: 1)
    expect(page).not_to have_selector("div.notification.unseen")
  end

  context "When user scrolls to bottom of notifications (infinity scroll)" do
    scenario 'User can see older notifications', :js => true do
      given_i_am_logged_in_as_a_user

      # and there are more notifications than fit on a page
      create_list(:post, Notification.per_page+1, :recipient => @user)

      # when I visit my notifications
      visit notifications_path

      # then I should see as many notifications as are shown per page
      expect(page).to have_selector(".notification", count: Notification.per_page)

      # when I scroll to the bottom
      page.driver.scroll_to(0, 10000)

      # then I should see as many notifications as are shown per page + 1
      expect(page).to have_selector(".notification", count: Notification.per_page+1)
    end
  end
end
