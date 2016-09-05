require 'rails_helper.rb'

feature 'Profile' do

  scenario 'User visits own profile' do
    given_i_am_logged_in_as_a_user
    when_i_visit_my_own_page
    then_i_should_see_my_profile
  end

  scenario 'User visits another profile' do
    given_i_am_logged_in_as_a_user
    when_i_visit_the_page_of_another_user
    then_i_should_see_their_profile
  end


  def given_i_am_logged_in_as_a_user
    @user = create(:user)
    visit login_path
    fill_in 'email',    with: @user.email
    fill_in 'password', with: @user.password
    click_button 'Login'
  end

  def when_i_visit_my_own_page
    visit profile_path @user.username
  end

  def when_i_visit_the_page_of_another_user
    @another_user = create(:user)
    visit profile_path @another_user.username
  end

  def then_i_should_see_my_profile
    expect(page).to have_content(@user.name)
  end

  def then_i_should_see_their_profile
    expect(page).to have_current_path("/" + @another_user.username)
    expect(page).to have_content(@another_user.name)
  end

end
