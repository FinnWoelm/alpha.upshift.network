require 'rails_helper.rb'

feature 'Search' do

  scenario 'User can search' do
    given_i_am_logged_in_as_a_user

    # and there are a few users named Brian
    5.times.with_index do |index|
      create(:network_user, :name => "Brian #{index}")
    end

    # when I visit the search page
    visit search_path

    # and search for Bob
    fill_in "query", with: "brian"
    click_on "Go"

    # then I should see five search results
    expect(page).to have_content("Brian", count: 5)
    expect(page).to have_selector("div.search_result", count: 5)
  end

  context "When user scrolls to bottom of search (infinity scroll)" do
    scenario 'User can see more search results', :js => true do

      # Given there are more public users (search results) than fit on a page
      create_list(:public_user, Search.per_page+1)
      User.update_all(:name => "Mahatma Gandhi")

      # when I visit the search page
      visit search_path

      # and search for Gandhi
      fill_in "query", with: "Gandhi"
      click_on "Go"

      # then I should see as many records as are shown per page
      expect(page).to have_selector("div.search_result", count: Search.per_page)

      # when I scroll to the bottom
      page.driver.scroll_to(0, 10000)

      # then I should see as many records as are shown per page + 1
      expect(page).to have_selector("div.search_result", count: Search.per_page+1)
    end
  end

  def given_i_am_logged_in_as_a_user
    @user = create(:user)
    visit login_path
    fill_in 'email',    with: @user.email
    fill_in 'password', with: @user.password
    click_button 'Login'
  end
end
