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

  context "When conversation is deleted" do
    scenario "New message will re-create that conversation" do
      given_i_am_logged_in_as_a_user
      and_i_have_some_private_conversations_with_messages
      when_i_go_to_my_private_conversations
      and_i_click_on_one_of_the_private_conversations
      and_the_conversation_gets_deleted
      and_i_send_a_new_message
      then_i_should_see_my_new_message_in_the_private_conversation
      and_have_created_a_new_private_conversation
    end
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
    3.times { |i| create(:private_conversation, :sender => @user, :recipient => @other_users[i]) }
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
    @my_message_text = Faker::Lorem.paragraph
    fill_in 'Message', with: @my_message_text
    click_on "Send Message"
  end

  def and_the_conversation_gets_deleted
    @user.private_conversations.destroy_all
  end

  def then_i_should_see_my_new_message_in_the_private_conversation
    expect(page).to have_content(@my_message_text)
  end

  def and_have_created_a_new_private_conversation
    expect(@user.private_conversations.reload.size).to eq 1
  end

end
