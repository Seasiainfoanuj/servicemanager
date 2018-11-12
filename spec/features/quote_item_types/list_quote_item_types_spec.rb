require "spec_helper"

feature "QuoteItemTypes" do

  background do
    quote_item_type1 = QuoteItemType.create(name: "Body", sort_order: 1, 
      allow_many_per_quote: false)
    quote_item_type2 = QuoteItemType.create(name: "Tyre", sort_order: 2, 
      allow_many_per_quote: false)
    @admin = create(:user, :admin)
  end

  scenario "Admin user views quote item type list", :js => true do
    sign_in @admin
    visit quote_item_types_path
    expect(page).to have_selector('h1', text: "Quote Item Types")
    within(".page-header") do
      expect(page).to have_content('Add New Quote Item Type')
    end
    within("tbody") do
      expect(page).to have_content('Body')
      expect(page).to have_content('Tyre')
    end
  end
end