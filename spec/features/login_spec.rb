require 'rails_helper.rb'

feature 'Login' do

  scenario 'User logs in' do
    given_i_am_a_user
    when_i_log_in
    then_i_should_be_logged_in
  end

  context 'User has not confirmed registration' do
    scenario 'User tries to log in' do
      given_i_am_a_user
      and_i_have_not_confirmed_my_registration
      when_i_log_in
      pending
      then_i_should_see_a_reminder_to_confirm_registration
    end

    scenario 'User tries to log in' do
      given_i_am_a_user
      and_i_have_not_confirmed_my_registration
      when_i_log_in
      pending
      and_expect_to_receive_a_new_confirmation_email
      and_request_a_new_confirmation_token
      then_i_should_see_a_success_message
    end
  end

  def given_i_am_a_user
    @user = create(:user)
  end

  def when_i_log_in
    visit login_path
    fill_in 'email',    with: @user.email
    fill_in 'password', with: @user.password
    click_button 'Login'
  end

  def then_i_should_be_logged_in
    expect(page).not_to have_content("Login")
  end

  def and_i_have_not_confirmed_my_registration
    @user.update_attributes(confirmed_registration: false)
  end

  def then_i_should_see_a_reminder_to_confirm_registration
    expect(page).to have_content("Your account has not yet been confirmed")
  end

end
