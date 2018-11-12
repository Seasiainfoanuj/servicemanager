require "spec_helper"

feature "New Quote" do
  background do
    create(:quote_item_type, name: 'Vehicle')
    @no_tax = Tax.create(name: "", rate: 0, number: "4231122", position: 0)
    @tax = Tax.create(name: "GST", rate: 0.1, number: "4238746", position: 1)
    create(:quote)
    @admin = create(:user, :admin)
    @customer = create(:user, :customer)
    @invoice_company = create(:invoice_company, accounts_admin: @admin)
  end

  scenario "New quote page contains initialised details" do
    sign_in @admin
    visit new_quote_path
    expect(page).to have_title(BUS4X4_ADMIN_APPL_NAME)
    expect(page).to have_selector('h1', text: "New Quote")

    expect(page).to have_content('Quote Number')
    expect(page).to have_content('Quote Date')
    expect(page).to have_content('PO Number/File')
    expect( find(:css, "input#quote_date_field").value).to eq(Date.today.strftime("%d/%m/%Y"))
    expect(page).to have_select "quote_invoice_company_id", with_options: [@invoice_company.name]
    expect(page).to have_select "quote_customer_id", with_options: ['Choose customer', @customer.company_name]
    expect(page).to have_select "quote_manager_id", with_options: ['Assign to a manager', @admin.company_name]
    expect( find(:css, "input#quote_number").value).not_to eq("")
    expect(page).to have_link("Add Line")
    expect(page).to have_link("Master Quote Items")

    find("#quote_invoice_company_id").find(:xpath, 'option[1]').select_option
    select @customer.company_name, from: "quote_customer_id"
    select @admin.company_name, from: "quote_manager_id"

    fill_in 'quote_items_attributes_0_name', :with => "First item"
    fill_in 'quote_items_attributes_0_description', :with => "First description"
    fill_in 'quote_items_attributes_0_cost', :with => "120.55"
    fill_in 'quote_items_attributes_0_quantity', :with => '1'
    select 'GST', from: 'quote_items_attributes_0_tax_id'
    select 'Vehicle', from: 'quote_items_attributes_0_quote_item_type_id'

    fill_in 'quote_terms', :with => "Terms of the quote"
    fill_in 'quote_comments', :with => "Comments on the quote"

    find("input#create-draft-submit").click
    expect(page).to have_content('Quote created')
    quote = Quote.last
    expect(page).to have_content("Quote #{quote.number}")
    expect(page).to have_content(@invoice_company.name)

    expect(page).to have_content(@customer.name)
    expect(page).to have_content(Date.today.strftime("%d/%m/%Y"))
    expect(page).to have_content("First description")
    expect(page).to have_content("120.55")
    expect(page).to have_content((120.55 * @tax.rate).round(2).to_s)
    expect(page).to have_content("Terms of the quote")
    expect(page).to have_content("Comments on the quote")
  end

end

