require "spec_helper"

feature "Edit Quote Item Type Page" do

  before(:each) do
    @admin = create(:user, :admin)
    @quote_item_type = QuoteItemType.create(
           name: 'Chassis',
           sort_order: 5,
           allow_many_per_quote: true
           )
  end

  scenario "Signed-in administrator edits quote_item_type", js: true do
    sign_in @admin
    visit edit_quote_item_type_path(@quote_item_type)
    expect(page).to have_selector('h1', text: "Edit Quote Item Type")

    expect( find(:css, "input#quote_item_type_name").value).to eq('Chassis')
    expect( find(:css, "input#quote_item_type_sort_order").value).to eq('5')
    expect( find(:css, "input#allow-many-checkbox").value).to eq('1')

    fill_in 'Name', with: 'Gearbox'
    fill_in 'Sort Order', with: 2
    find(:css, "ins.iCheck-helper").click

    within(".actions") do
      find(:css, ".submit-btn").click
    end

    expect(page).to have_content("Quote Item Type updated.")
    expect(QuoteItemType.count).to eq(1)
    expect(page).to have_content("Gearbox")
    expect(page).to have_content("NO")

  end
end
