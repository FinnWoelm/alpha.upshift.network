require 'rails_helper.rb'

feature 'User' do

  scenario 'User visits own profile' do
    given_i_am_logged_in_as_a_user
    when_i_visit_my_own_page
    then_i_should_see_my_profile
  end

  scenario "User visits another user's profile" do
    given_i_am_logged_in_as_a_user
    when_i_visit_the_page_of_another_user
    then_i_should_see_their_profile
  end

  scenario 'User can write a post on the profile of someone else' do
    given_i_am_logged_in_as_a_user

    # when I visit the page of another user
    @another_user = create(:user)
    visit @another_user

    # and I write a post
    @my_post_content = Faker::Lorem.paragraph
    fill_in 'post_content', with: @my_post_content
    click_button "Post"

    # then I should have posted on the other user's profile
    expect(page).to have_content(@my_post_content)
  end

  context "When user scrolls to bottom of profile (infinity scroll)" do
    scenario 'User can see older posts', :js => true do
      given_i_am_logged_in_as_a_user

      # and there is a user with more posts than fit on a page
      @another_user = create(:user)
      create_list(:post_to_self, Post.per_page+1, :author => @another_user)

      # when I visit their profile
      visit @another_user

      # then I should see as many posts as are shown per page
      expect(page).to have_selector(".post-wrapper:not(.post_form)", count: Post.per_page)

      # when I scroll to the bottom
      page.driver.scroll_to(0, 10000)

      # then I should see as many conversations as are shown per page + 1
      expect(page).to have_selector(".post-wrapper:not(.post_form)", count: Post.per_page+1)
    end
  end

  def given_i_am_logged_in_as_a_user
    @user = create(:user)
    visit login_path
    fill_in 'email',    with: @user.email
    fill_in 'password', with: @user.password
    click_button 'Login'
  end

  def when_i_visit_my_own_page
    visit @user
  end

  def when_i_visit_the_page_of_another_user
    @another_user = create(:user)
    visit @another_user
  end

  def then_i_should_see_my_profile
    expect(page).to have_content(@user.name)
  end

  def then_i_should_see_their_profile
    expect(page).to have_current_path("/" + @another_user.username)
    expect(page).to have_content(@another_user.name)
  end

end
