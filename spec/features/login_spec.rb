require 'rails_helper.rb'

feature 'Login' do

  scenario 'User logs in' do
    # given_i_am_a_user
    @user = create(:user)

    # when_i_log_in
    visit login_path
    fill_in 'email',    with: @user.email
    fill_in 'password', with: @user.password
    click_button 'Login'

    # then_i_should_be_logged_in
    expect(page).not_to have_content("Login")
  end
end
