require "spec_helper"

feature "Quote cover letter management" do
  background do
    @admin = create(:user, :admin)
    @quote_customer = create(:user, :quote_customer)

    @quote = create(:quote, number: "QUOTE-1", customer: @quote_customer)
  end

  scenario "adding cover letter to quote", :js => true do
    sign_in @admin
    visit edit_quote_path(@quote)

    click_on 'Add Cover Letter'

    within("#quote-cover-letter-form") do
      fill_in 'quote_cover_letter_title', :with => "Test Cover Letter Title"
      fill_in 'quote_cover_letter_text', :with => "This is my message!"
      # fill_in_ckeditor 'quote_cover_letter_text', :with => 'This is my message!'
    end

    within(".actions") do
      click_on 'Create Cover Letter'
    end

    expect(current_path).to eq edit_quote_path(@quote)
    expect(page).to have_content("Cover Letter")
  end

  scenario "cover letter appears on quote" do
    quote = create(:quote)
    create(:quote_cover_letter, quote_id: @quote.id)

    sign_in @admin
    visit quote_path(quote)

    expect(page).to_not have_css('#cover-letter')

    visit quote_path(@quote)
    expect(page).to have_css('#cover-letter')
  end
end
