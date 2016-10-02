require 'rails_helper.rb'

feature 'Login' do

  scenario 'User can register' do
    given_i_am_a_visitor
    when_i_go_to_the_registration_page
    and_i_submit_my_information
    then_i_should_be_a_registered_user
  end

  scenario 'User receives confirmation email' do
    pending
    given_i_am_a_visitor
    when_i_register
    then_i_should_receive_a_confirmation_email
  end

  scenario 'User can confirm registration' do
    pending
    given_i_am_a_visitor
    when_i_register
    and_i_confirm_the_registration
    then_i_should_be_a_registered_user_with_confirmed_registration
    and_i_should_be_able_to_log_in
  end

  def given_i_am_a_visitor
    @user = build(:user)
  end

  def when_i_go_to_the_registration_page
    visit new_registration_path
  end

  def and_i_submit_my_information
    fill_in 'Name',                   with: @user.name
    fill_in 'Username',               with: @user.username
    fill_in 'Email',                  with: @user.email
    fill_in 'Password',               with: @user.password
    fill_in 'Confirm your password',  with: @user.password
    click_button 'Sign Up'
  end

  def then_i_should_be_a_registered_user
    expect(User.find_by_email(@user.email)).to be_present
  end

  def when_i_register
    when_i_go_to_the_registration_page
    and_i_submit_my_information
  end

  def then_i_should_receive_a_confirmation_email
    expect(Mailjet::Send).to receive(:create)
  end

  def then_i_should_be_logged_in
    expect(page).not_to have_content("Login")
  end

  def and_i_confirm_the_registration
    visit confirm_registrations_path
  end

  def then_i_should_be_a_registered_user_with_confirmed_registration
    User.find_by_email(@user.email).to have_confirmed_registration
  end

  def and_i_should_be_able_to_log_in
    visit login_path
    fill_in 'email',    with: @user.email
    fill_in 'password', with: @user.password
    click_button 'Login'
    expect(page).not_to have_content("Login")
  end

end
