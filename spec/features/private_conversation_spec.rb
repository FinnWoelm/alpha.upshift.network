require 'rails_helper.rb'

feature 'Private Conversation' do

  scenario 'User can see conversations' do
    given_i_am_logged_in_as_a_user
    and_i_have_some_private_conversations
    when_i_go_to_my_private_conversations
    then_i_should_see_my_private_conversations
  end

  scenario "User can start a new conversation" do
    given_i_am_logged_in_as_a_user
    and_there_is_a_user_i_want_to_message
    when_i_go_to_my_private_conversations
    and_i_start_a_new_private_conversation_with_the_user_i_want_to_message
    then_i_should_have_started_a_new_private_conversation_with_that_user
  end

  context "When a conversation with recipient already exists" do
    scenario "New message will be appended to that conversation" do
      given_i_am_logged_in_as_a_user
      and_there_is_a_user_i_want_to_message
      and_i_am_already_in_a_conversation_with_that_user
      when_i_go_to_my_private_conversations
      and_i_start_a_new_private_conversation_with_the_user_i_want_to_message
      then_i_should_have_added_a_message_to_the_existing_conversation
    end
  end

  scenario 'User can delete a conversation' do
    given_i_am_logged_in_as_a_user
    and_i_have_some_private_conversations
    when_i_go_to_my_private_conversations
    and_i_delete_one_of_the_private_conversations
    then_i_should_no_longer_see_that_private_conversation
  end

  def given_i_am_logged_in_as_a_user
    @user = create(:user)
    visit login_path
    fill_in 'email',    with: @user.email
    fill_in 'password', with: @user.password
    click_button 'Login'
  end

  def and_i_have_some_private_conversations
    @other_users = []
    3.times { @other_users << create(:user)}
    3.times do |i|
      create(:private_conversation,
        :sender => @user,
        :recipient => @other_users[i]
      )
    end
  end

  def when_i_go_to_my_private_conversations
    visit private_conversations_home_path
  end

  def then_i_should_see_my_private_conversations
    @other_users.each do |u|
      expect(page).to have_content("Conversation with #{u.name}")
    end
  end

  def and_there_is_a_user_i_want_to_message
    @user_to_message = create(:user)
  end

  def and_i_am_already_in_a_conversation_with_that_user
    @existing_conversation =
      create(:private_conversation, :sender => @user, :recipient => @user_to_message)
    @initial_message_count = @existing_conversation.messages.count
  end

  def and_i_start_a_new_private_conversation_with_the_user_i_want_to_message
    click_on "Start a new Conversation"
    fill_in 'Recipient', with: @user_to_message.username
    fill_in 'Message',  with: Faker::Lorem.paragraph
    click_on "Create Conversation"
  end

  def then_i_should_have_started_a_new_private_conversation_with_that_user
    expect(PrivateConversation.find_conversations_between([@user, @user_to_message])).to be_any
  end

  def then_i_should_have_added_a_message_to_the_existing_conversation
    expect(@existing_conversation.reload.messages.count).to eq(@initial_message_count + 1)
  end

  def and_i_delete_one_of_the_private_conversations
    click_on "Delete conversation with #{@other_users[0].name}"
  end

  def then_i_should_no_longer_see_that_private_conversation

    # not see the first conversation
    [@other_users[0]].each do |u|
      expect(page).not_to have_content("Conversation with #{u.name}")
    end

    # still see the other conversations
    (@other_users - [@other_users[0]]).each do |u|
      expect(page).to have_content("Conversation with #{u.name}")
    end
  end

end
