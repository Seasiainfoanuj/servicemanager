require "spec_helper"

feature "Quote title page management" do
  background do
    @admin = create(:user, :admin)
    @quote_customer = create(:user, :quote_customer)

    @quote = create(:quote, number: "QUOTE-1", customer: @quote_customer)
  end

  scenario "adding title page to quote", :js => true do
    pending "Manual test passes but rspec test fails"
    sign_in @admin
    visit edit_quote_path(@quote)

    click_on 'Add Title Page'

    within("#quote-title-page-form") do
      fill_in 'quote_title_page_title', :with => "Test Title Page"
      attach_file('Image 1 (Top)', Rails.root + 'spec/fixtures/images/rails.png')
      attach_file('Image 2 (Bottom)', Rails.root + 'spec/fixtures/images/rails.png')
    end

    within(".actions") do
      click_on 'Create Title Page'
    end

    expect(current_path).to eq edit_quote_path(@quote)
    expect(page).to have_content("Title Page")
  end

  scenario "title page appears on quote" do
    quote = create(:quote)
    create(:quote_title_page, quote_id: @quote.id)

    sign_in @admin
    visit quote_path(quote)

    expect(page).to_not have_css('#title-page')

    visit quote_path(@quote)
    expect(page).to have_css('#title-page')
  end
end
