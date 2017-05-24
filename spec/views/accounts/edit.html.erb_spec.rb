require 'rails_helper'

RSpec.describe "accounts/edit.html.erb", type: :view do

  let(:account) { create(:account) }
  before { assign(:account, account) }

  it "refers the user to edit their profile to change name, visibility, ..." do
    render
    expect(rendered).to have_text("To change your")
    expect(rendered).to have_text("click the button to edit your profile")
  end

end
