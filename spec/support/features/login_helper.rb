# function to use for logging in as a user
def given_i_am_logged_in_as_a_user
  @user = create(:user)
  visit login_path
  fill_in 'email',    with: @user.account.email
  fill_in 'password', with: @user.account.password
  click_button 'Login'
end
