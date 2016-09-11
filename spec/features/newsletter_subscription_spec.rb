require 'rails_helper.rb'

feature 'Newsletter Subscription' do

  before do
    allow(Mailjet::Send).to receive(:create)
  end

  scenario 'Visitor can subscribe', :js => true do
    given_i_visit_the_home_page
    when_i_click_join
    and_i_submit_my_information
    and_i_expect_to_receive_a_confirmation_email
    then_i_should_see_a_success_message
    and_be_a_pending_subscriber
  end

  scenario 'Visitor can confirm subscription' do
    given_i_am_a_pending_subscriber
    when_i_expect_to_be_added_to_the_list_of_subscribers
    and_i_visit_the_confirmation_url
    then_i_should_see_a_confirmation_message
  end

  # Visitor can subscribe ######################################################

  def given_i_visit_the_home_page
    visit root_path
  end

  def when_i_click_join
    click_on "Join"
  end

  def and_i_submit_my_information
    @name = Faker::Name.name
    @email = Faker::Internet.email
    fill_in 'Name',   with: @name
    fill_in 'Email',  with: @email
    click_on 'Join Our Newsletter'
  end

  def and_i_expect_to_receive_a_confirmation_email
    expect(Mailjet::Send).to receive(:create)
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content "Thank you for joining, #{@name}!"
  end

  def and_be_a_pending_subscriber
    expect(PendingNewsletterSubscription).to exist(:email => @email)
  end

  # Visitor can confirm subscription ###########################################

  def given_i_am_a_pending_subscriber
    @pending_newsletter_subscription =
      create(:pending_newsletter_subscription)
  end

  def when_i_expect_to_be_added_to_the_list_of_subscribers
    expect(Mailjet::Contactslist_managecontact).to receive(:create)
  end

  def and_i_visit_the_confirmation_url
    visit confirm_pending_newsletter_subscriptions_path(
      :email => @pending_newsletter_subscription.email,
      :confirmation_token => @pending_newsletter_subscription.confirmation_token
      )
  end

  def then_i_should_see_a_confirmation_message
    expect(page).to have_content("Thank you")
  end

end
