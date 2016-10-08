require 'rails_helper.rb'

feature 'Login' do

  scenario 'User logs in' do
    given_i_am_a_user
    when_i_log_in
    then_i_should_be_logged_in
  end

  context 'User has not confirmed registration' do

    before do
      allow(Mailjet::Send).to receive(:create)
    end

    scenario 'User tries to log in' do
      given_i_am_a_user
      and_i_have_not_confirmed_my_registration
      when_i_log_in
      then_i_should_see_a_reminder_to_confirm_registration
    end

    scenario 'User tries to log in', :js => true do
      given_i_am_a_user
      and_i_have_not_confirmed_my_registration
      when_i_log_in
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
    expect(page).to have_content("You have not yet confirmed your registration")
  end

  def and_expect_to_receive_a_new_confirmation_email
    expect(Mailjet::Send).to receive(:create)
  end

  def and_request_a_new_confirmation_token
    click_on 'Re-send Confirmation Email'
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content("Confirmation email has been resent".upcase)
  end

end
