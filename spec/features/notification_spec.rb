require 'rails_helper.rb'

feature 'Notification' do

  scenario 'User can see notifications' do
    given_i_am_logged_in_as_a_user

    # and I have received a post from Brian
    @brian = create(:user, :name => "Brian")
    create(:post, :author => @brian, :recipient => @user)

    # when I visit my notifications
    visit notifications_path

    # then I should see a notification from Brian
    expect(page).to have_content("#{@brian.name} posted on your profile")
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

      # then I should see as many notificatios as are shown per page
      expect(page).to have_selector(".notification", count: Notification.per_page)

      # when I scroll to the bottom
      page.driver.scroll_to(0, 10000)

      # then I should see as many conversations as are shown per page + 1
      expect(page).to have_selector(".notification", count: Notification.per_page+1)
    end
  end



  def given_i_am_logged_in_as_a_user
    @user = create(:user)
    visit login_path
    fill_in 'email',    with: @user.email
    fill_in 'password', with: @user.password
    click_button 'Login'
  end
end
