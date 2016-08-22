require 'rails_helper.rb'

feature 'Newsletter Subscription' do

  scenario 'Visitor can subscribe' do
    given_i_visit_the_home_page
    when_i_click_join
    and_i_submit_my_information
    then_i_should_see_a_success_message
  end

  def given_i_visit_the_home_page
    visit root_path
  end

  def when_i_click_join

    click_on "Join"
  end

  def and_i_submit_my_information
    fill_in 'name',   with: 'my name'
    fill_in 'email',  with: 'user@example.com'
    click_on 'Join'
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content "Thank you for joining"
  end

end
