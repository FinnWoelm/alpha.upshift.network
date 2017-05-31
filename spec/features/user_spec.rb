require 'rails_helper.rb'
require 'support/features/login_helper.rb'

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

  scenario "User can edit profile" do
    given_i_am_logged_in_as_a_user

    # when I edit my profile
    visit edit_user_path @user

    # and I change my banner, picture, name, color scheme, bio, and visibility
    attach_file('user[profile_banner]', "#{Rails.root}/spec/support/fixtures/community/user/profile_banner.jpg")
    attach_file('user[profile_picture]', "#{Rails.root}/spec/support/fixtures/community/user/profile_picture.jpg")
    fill_in 'user[name]',       with: "My new name"
    select "Indigo",            from: 'user[color_scheme_base]'
    select "Accent 2",          from: 'user[color_scheme_shade]'
    fill_in 'user[bio]',        with: "Hey y'all, looking forward to meet you :)"
    select 'Public',            from: 'user[visibility]'

    # and click save
    click_on "Save"

    # then I should see my profile
    expect(page).to have_current_path user_path(@user)

    # and my banner, picture, name, color scheme, bio, and visibility
    expect(@user.reload.profile_banner).to be_present
    expect(@user.profile_picture).to be_present
    expect(@user.options[:auto_generate_profile_picture]).to be false
    expect(page).to have_content "My new name"
    expect(page).to have_selector "body.primary-indigo.primary-accent-2"
    expect(page).to have_content "Hey y'all, looking forward to meet you :)"
    expect(@user.visibility).to eq "public"
  end

  scenario "User can remove profile banner", :js => true do
    given_i_am_logged_in_as_a_user

    # and I have a profile banner
    @user.profile_banner = File.new("#{Rails.root}/spec/support/fixtures/community/user/profile_banner.jpg")
    @user.save

    # when I edit my profile
    visit edit_user_path @user

    # and I click the remove profile banner button
    within '.profile_banner' do
      find(".remove").click
    end

    # and I save
    click_on "Save"

    # then I should not have a profile banner
    expect(@user.reload.profile_banner).not_to be_present
  end

  scenario "User can remove profile banner", :js => true do
    given_i_am_logged_in_as_a_user

    # and I have a profile picture
    @user.profile_picture = File.new("#{Rails.root}/spec/support/fixtures/community/user/profile_picture.jpg")
    @user.save

    # when I edit my profile
    visit edit_user_path @user

    # and I click the remove profile picture button
    within '.profile_picture' do
      find(".remove").click
    end

    # and I save
    click_on "Save"

    # then my profile picture should be auto-generated
    expect(@user.reload.profile_picture).to be_present
    expect(@user.options[:auto_generate_profile_picture]).to be true
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
