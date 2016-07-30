require 'rails_helper.rb'

feature 'Private Message' do

  scenario 'User can see messages in a conversation' do
    given_i_am_logged_in_as_a_user
    and_i_have_some_private_conversations_with_messages
    when_i_go_to_my_private_conversations
    and_i_click_on_one_of_the_private_conversations
    then_i_should_see_the_messages_in_that_private_conversation
  end

  scenario "User can send a message in a conversation" do
    given_i_am_logged_in_as_a_user
    and_i_have_some_private_conversations_with_messages
    when_i_go_to_my_private_conversations
    and_i_click_on_one_of_the_private_conversations
    and_i_send_a_new_message
    then_i_should_see_my_new_message_in_the_private_conversation
  end

  def given_i_am_logged_in_as_a_user
    @user = create(:user)
    visit login_path
    fill_in 'email',    with: @user.email
    fill_in 'password', with: @user.password
    click_button 'Login'
  end

  def and_i_have_some_private_conversations_with_messages
    @other_users = []
    3.times { @other_users << create(:user)}
    3.times { |i| PrivateConversation.create(:sender => @user, :recipient => @other_users[i]) }
    @user.private_conversations.find_each do |conversation|
      3.times { |i| PrivateMessage.create(:sender => @user, :conversation => conversation, :content => "My message #{i}") }
    end
  end

  def when_i_go_to_my_private_conversations
    visit private_conversations_home_path
  end

  def and_i_click_on_one_of_the_private_conversations
    click_on "Conversation with #{@other_users[0].name}"
  end

  def then_i_should_see_the_messages_in_that_private_conversation
    expect(page).to have_content("Conversation with #{@other_users[0].name}")
    expect(page).to have_content("My message 0")
    expect(page).to have_content("My message 1")
    expect(page).to have_content("My message 2")
  end

  def and_i_send_a_new_message
    @my_message_text =
    fill_in 'Message',  with: Faker::Lorem.paragraph
    click_on "Send"
  end

  def then_i_should_see_my_new_message_in_the_private_conversation
    expect(page).to have_content(@my_message_text)
  end

end
