require "spec_helper"
include ActionView::Helpers::NumberHelper

feature "Update Quote" do
  background do
    tax = Tax.find_by(name: "") || create(:tax, name: "", rate: 0)
    tax_gst = create(:tax, name: "GST", rate: 0.10)
    create(:quote_item_type, name: 'Body')
    create(:quote_item_type, name: 'Chassis')
    invoice_company = create(:invoice_company_2, name: 'I-BUS', slug: 'i-bus')

    address1 = build(:address, address_type: Address::POSTAL)
    address2 = build(:address, address_type: Address::PHYSICAL)
    @manager = build(:user, :admin)
    @manager.addresses.build(address1.attributes)
    @manager.save!

    @customer = build(:user, :customer)
    @customer.addresses.build(address2.attributes)
    @customer.save!
    @quote = build(:quote, number: "QUOTE-1", status: 'draft',
                    customer: @customer, manager: @manager,
                    invoice_company: invoice_company)
    @quote_item = build(:quote_item, tax: tax_gst)
    @quote.items.build( @quote_item.attributes )
    @quote.save

  end

  scenario "admin can view the quotes", :js => true do
    sign_in @manager
    visit quote_path(@quote)

    expect(page).to have_title('Bus 4x4 - Service Manager')

    within("#quote") do
      expect(page).to have_content('DRAFT')
    end

    within("#quote .invoice-info .invoice-name") do
      expect(page).to have_content("Quote #{@quote.number}")
    end

    within(".page-header") do
      find(:css, ".edit-quote").click
      expect(page).to have_content("Edit Quote: #{@quote.number}")
    end

    quote_item = @quote.items.first
    quote_item_type_id = quote_item.quote_item_type.id

    within("table#form-table") do
      expect( find(:css, "input#quote_items_attributes_0_name").value).to eq(quote_item.name)
      within("textarea#quote_items_attributes_0_description") do
        expect(page).to have_content(quote_item.description.first)
      end
      expect( find(:css, "input#quote_items_attributes_0_cost").value).to eq(number_with_precision((quote_item.cost_cents / 100.0).round(2), precision: 2))
      expect( find(:css, "input#quote_items_attributes_0_quantity").value).to eq(quote_item.quantity.to_s)
      expect( find(:css, "select#quote_items_attributes_0_tax_id option[selected='selected']")).to have_content('GST')
      formatted_number = number_with_precision(quote_item.cost.fractional * quote_item.quantity / 100.0, precision: 2, separator: '.', delimiter: ',')
      expect( find(:css, "td.line-total span")).to have_content(formatted_number.to_s)
      expect( find(:css, "select#quote_items_attributes_0_quote_item_type_id").value).to eq(quote_item_type_id.to_s)
    end

    within("table#form-table") do
      fill_in "quote_items_attributes_0_name", with: 'New Item Name'
      fill_in "quote_items_attributes_0_description", with: 'New Item description'
      select "Chassis", from: "quote_items_attributes_0_quote_item_type_id"
    end

    within("form#quote_form") do
      click_button('Update')
    end

    expect(page).to have_content('Quote updated.')
    expect(page).to have_content('New Item Name')
    expect(page).to have_content('New Item description')
    expect(page).to have_content('Chassis')

  end
end

