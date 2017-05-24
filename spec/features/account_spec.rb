require 'rails_helper.rb'
require 'support/features/login_helper.rb'

feature 'Account' do

  scenario 'User can change their password' do
    given_i_am_logged_in_as_a_user

    # when I go to settings
    visit edit_account_path

    # and enter my current password
    fill_in 'account_current_password', with: @user.account.password
    fill_in 'account_password', with: "my_new_password"
    fill_in 'account_password_confirmation', with: "my_new_password"
    click_on "Change Password"

    # then I should see a success message
    expect(page).to have_text "Password successfully changed"

    # and my password should be "my new password"
    expect(@user.account.reload.authenticate("my_new_password")).to be_truthy
  end
end
