require 'rails_helper.rb'
require 'support/features/login_helper.rb'

feature 'Private Message' do

  scenario 'User can see messages in a conversation' do
    given_i_am_logged_in_as_a_user
    and_i_have_some_private_conversations_with_messages
    when_i_go_to_my_private_conversations
    and_i_click_on_one_of_the_private_conversations
    then_i_should_see_the_messages_in_that_private_conversation
  end

  context "When user scrolls to top of conversation (infinity scroll)" do
    scenario 'User can see older messages', :js => true do
      given_i_am_logged_in_as_a_user

      # and I have a private conversation with more messages than are shown per page
      @conversation = create(:private_conversation, :sender => @user)
      create_list(:private_message, PrivateMessage.per_page+1, :conversation => @conversation)

      # when I go to the private conversation
      visit private_conversation_path @conversation

      # then I should see as many messages as are shown per page
      expect(page).to have_selector("#chat_body .private_message", count: PrivateMessage.per_page)

      # when I scroll to the top (after not being at the top of the page)
      page.driver.scroll_to(0, 10000)
      page.driver.scroll_to(0, 0)

      # then I should see as many messages as are shown per page + 1
      expect(page).to have_selector("#chat_body .private_message", count: PrivateMessage.per_page+1)
    end
  end

  context "When new messages in the conversation are received" do
    scenario "User can see new messages without reloading", :js => true do
      given_i_am_logged_in_as_a_user
      and_i_have_some_private_conversations_with_messages
      when_i_go_to_my_private_conversations
      and_i_click_on_one_of_the_private_conversations
      and_i_receive_new_messages
      then_i_should_see_the_new_messages
    end
  end

  scenario "User can send a message in a conversation", :js => true do
    given_i_am_logged_in_as_a_user
    and_i_have_some_private_conversations_with_messages
    when_i_go_to_my_private_conversations
    and_i_click_on_one_of_the_private_conversations
    and_i_send_a_new_message
    then_i_should_see_my_new_message_in_the_private_conversation
    and_i_should_see_my_new_message_in_the_side_nav
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
    click_on "#{@other_users[0].name}"
  end

  def then_i_should_see_the_messages_in_that_private_conversation
    expect(page).to have_content("#{@other_users[0].name}")
    expect(page).to have_content("My message 0")
    expect(page).to have_content("My message 1")
    expect(page).to have_content("My message 2")
  end

  def and_i_send_a_new_message
    @my_message_text = Faker::Lorem.paragraph
    fill_in 'Message', with: @my_message_text
    click_on "Send Message"
  end

  def and_i_receive_new_messages
    @new_message = PrivateMessage.create(
      :sender => @other_users[0],
      :conversation => PrivateConversation.find_conversations_between([@user, @other_users[0]]).first,
      :content => "This message should be fetched automatically"
    )
  end

  def then_i_should_see_the_new_messages
    expect(page).to have_content ("This message should be fetched automatically")
  end


  def then_i_should_see_my_new_message_in_the_private_conversation
    expect(page).to have_content(@my_message_text)
  end

  def and_i_should_see_my_new_message_in_the_side_nav
    expect(page).to have_selector("#mobile_navigation a.preview_conversation span.content", text: @my_message_text[0..10])
    expect(page).to have_selector("#desktop_side_navigation a.preview_conversation span.content", text: @my_message_text[0..10])
  end


end
