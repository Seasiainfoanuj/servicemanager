require "spec_helper"

feature "Quote management" do
  let(:quote_item_type_1 ) { create(:quote_item_type, name: 'Body') }
  let(:quote_item_type_2 ) { create(:quote_item_type, name: 'Accessory') }
  let(:title_page) { create(:quote_title_page) }
  let(:cover_letter) { create(:quote_cover_letter) }

  background do
    @admin = User.admin.first || create(:user, :admin, client_attributes: { client_type: 'person'})
    @supplier = User.supplier.first || create(:user, :supplier, client_attributes: { client_type: 'person'})
    @service_provider = User.service_provider.first || create(:user, :service_provider, client_attributes: { client_type: 'person'})
    @customer = User.customer.first || create(:user, :customer, client_attributes: { client_type: 'person'})
    @quote_customer = User.quote_customer.first || create(:user, :quote_customer, client_attributes: { client_type: 'person'})

    @admin_quote = create(:quote, number: "QUOTE-1", customer: @admin)
    @supplier_quote = create(:quote, number: "QUOTE-2", customer: @supplier)
    @sp_quote = create(:quote, number: "QUOTE-3", customer: @service_provider)
    @customer_quote = create(:quote, number: "QUOTE-4", customer: @customer)
    @quote_customer_quote = create(:quote, number: "QUOTE-5", customer: @quote_customer)
  end

  scenario "admin can view all quotes", :js => true do
    sign_in @admin
    visit quotes_path

    expect(page).to have_content @admin_quote.number
    expect(page).to have_content @supplier_quote.number
    expect(page).to have_content @sp_quote.number
  end

  scenario "supplier can only view their quotes", :js => true do
    sign_in @supplier
    visit quotes_path

    expect(page).to have_content @supplier_quote.number

    expect(page).to_not have_content @admin_quote.number
    expect(page).to_not have_content @sp_quote.number

    visit quote_path(@admin_quote)
    expect(page).to have_content 'You are not authorized to access this page.'
  end

  scenario "service provider can only view their quotes", :js => true do
    sign_in @service_provider
    visit quotes_path

    expect(page).to have_content @sp_quote.number

    expect(page).to_not have_content @admin_quote.number
    expect(page).to_not have_content @supplier_quote.number
  end

  scenario "customer can only view their quotes", :js => true do
    sign_in @customer
    visit quotes_path

    expect(page).to have_content @customer_quote.number

    expect(page).to_not have_content @admin_quote.number
    expect(page).to_not have_content @supplier_quote.number
  end

  scenario "quote customer can only view their quotes", :js => true do
    sign_in @quote_customer
    visit quotes_path

    expect(page).to have_content @quote_customer_quote.number

    expect(page).to_not have_content @admin_quote.number
    expect(page).to_not have_content @supplier_quote.number
  end

  scenario "can be filtered by user", :js => true do
    sign_in @admin
    visit quotes_path

    within("tbody") do
      expect(page).to have_content @admin_quote.number
      expect(page).to have_content @quote_customer_quote.number
    end

    visit user_quotes_path(@quote_customer)
    expect(page.status_code).to eq 200

    within("tbody") do
      expect(page).to have_content @quote_customer_quote.number
      expect(page).to_not have_content @admin_quote.number
    end
  end

  scenario "admin can duplicate quote" do

    item_1 = build(:quote_item, quote: @admin_quote, quote_item_type: quote_item_type_1)
    item_2 = build(:quote_item, quote: @admin_quote, quote_item_type: quote_item_type_2)
    item_3 = build(:quote_item, quote: @admin_quote, quote_item_type: quote_item_type_2)

    quote = create(:quote,
      title_page: title_page,
      cover_letter: cover_letter,
      items: [item_1, item_2, item_3]
    )

    sign_in @admin
    visit "/quotes/#{quote.id}/duplicate"

    new_quote = Quote.last

    expect(new_quote.number).to eq quote.number.next
    expect(new_quote.status).to eq "draft"
    expect(new_quote.items.count).to eq 3
    expect(new_quote.title_page.title).to eq title_page.title
    expect(new_quote.cover_letter.text).to eq cover_letter.text
  end

  scenario "admin can create amended quote" do
    title_page = create(:quote_title_page)
    cover_letter = create(:quote_cover_letter)

    item_1 = create(:quote_item, quote: @admin_quote, quote_item_type: quote_item_type_1)
    item_2 = create(:quote_item, quote: @admin_quote, quote_item_type: quote_item_type_2)
    item_3 = create(:quote_item, quote: @admin_quote, quote_item_type: quote_item_type_2)

    quote = create(:quote,
      title_page: title_page,
      cover_letter: cover_letter,
      items: [item_1, item_2, item_3]
    )

    sign_in @admin
    visit "/quotes/#{quote.id}/create_amendment"

    expect(page).to have_content "Quote #{quote.number} cancelled and amendment created. Continue editing below."

    amended_quote = Quote.last
    
    expect(Quote.all[-2]).to eq quote
    expect(Quote.all[-2].status).to eq 'cancelled'

    expect(amended_quote.amendment).to eq true
    expect(amended_quote.number).to eq "#{quote.number}-1"
    expect(amended_quote.status).to eq "draft"
    expect(amended_quote.items.count).to eq 3
    expect(amended_quote.title_page.title).to eq title_page.title
    expect(amended_quote.cover_letter.text).to eq cover_letter.text

    visit "/quotes/#{amended_quote.id}/create_amendment"
    second_amended_quote = Quote.last

    expect(Quote.all[-2]).to eq amended_quote
    expect(Quote.all[-2].status).to eq 'cancelled'

    expect(second_amended_quote.amendment).to eq true
    expect(second_amended_quote.number).to eq amended_quote.number.next
    expect(second_amended_quote.status).to eq "draft"
    expect(second_amended_quote.items.count).to eq 3
    expect(second_amended_quote.title_page.title).to eq amended_quote.title_page.title
    expect(second_amended_quote.cover_letter.text).to eq amended_quote.cover_letter.text
  end
end
