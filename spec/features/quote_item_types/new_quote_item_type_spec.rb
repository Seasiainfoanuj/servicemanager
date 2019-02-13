require "spec_helper"

feature "New Quote Item Type Page" do

  before(:each) do
    @admin = User.admin.first || create(:user, :admin)
  end

  scenario "Signed-in administrator creates new Quote Item Type", js: true do
    sign_in @admin
    visit new_quote_item_type_path
    expect(page).to have_selector('h1', text: "New Quote Item Type")

    fill_in 'Name', with: 'Gearbox'
    fill_in 'Sort Order', with: 2
    find(:css, "ins.iCheck-helper").click

    within(".actions") do
      find(:css, ".submit-btn").click
    end

    expect(page).to have_content("Quote Item Type created.")
    expect(QuoteItemType.count).to eq(1)
    expect(page).to have_content("Gearbox")
    expect(page).to have_content("YES")
  end
end