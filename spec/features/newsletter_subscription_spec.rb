require 'rails_helper.rb'

feature 'Newsletter Subscription' do

  scenario 'Visitor can subscribe', :js => true do
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
    @name = Faker::Name.name
    @email = Faker::Internet.email
    fill_in 'name',   with: @name
    fill_in 'email',  with: @email
    click_on 'Join Our Newsletter'
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content "Thank you for joining, #{@name}!"
  end

end
