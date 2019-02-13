require "spec_helper"

feature "Master quote management" do
  background do
    @admin = create(:user, :admin, client_attributes: { client_type: 'person'})
    @supplier = create(:user, :supplier, client_attributes: { client_type: 'person'})
    @service_provider = create(:user, :service_provider, client_attributes: { client_type: 'person'})
    @customer = create(:user, :customer, client_attributes: { client_type: 'person'})
    @quote_customer = create(:user, :quote_customer, client_attributes: { client_type: 'person'})

    @master_quote_1 = create(:master_quote, name: "MASTER-QUOTE-1")
  end

  feature "master quote types" do
    scenario "create, view update and destroy quote types", :js => true do
      sign_in @admin
      visit new_master_quote_type_path

      within("#master-quote-type-form") do
        fill_in 'master_quote_type_name', :with => "TYPE-999"
      end

      within(".page-header") do
        click_on 'Create Master Quote Type'
      end

      expect(current_path).to eq master_quote_types_path
      expect(page).to have_content "TYPE-999"
      expect(page).to have_css ".delete-btn"

      master_quote_type = MasterQuoteType.find_by_name!("TYPE-999")
      expect(master_quote_type).to be_valid

      visit edit_master_quote_type_path(master_quote_type)
      expect(page).to have_content "Edit TYPE-999"
    end
  end

  feature "creating master quote" do

    let (:item_type) { create(:quote_item_type, name: 'Accessory') }

    background do
      @master_quote_type = create(:master_quote_type, name: "TYPE1")
      @master_quote_item = create(:master_quote_item, quote_item_type: item_type)
      @tax = create(:tax, name: "GST2")
    end

    scenario "adding new master quote items", :js => true do
      expect{
        sign_in @admin
        visit new_master_quote_path

        within("#master-quote-form") do
          select('TYPE1', :from => 'master_quote_master_quote_type_id')
          fill_in 'master_quote_name', :with => "Test Master Quote"
          fill_in 'master_quote_items_attributes_0_name', :with => "Test Item"
          fill_in 'master_quote_items_attributes_0_description', :with => "Test Description"
          fill_in 'master_quote_items_attributes_0_quantity', :with => 10
          select('Accessory', :from => 'master_quote_items_attributes_0_quote_item_type_id')
          select("GST2", :from => 'master_quote_items_attributes_0_cost_tax_id')
          click_on 'Create'
        end

        expect(current_path).to eq master_quote_path(MasterQuote.last)
        expect(page).to have_content "Test Master Quote"

      }.to change(MasterQuoteItem, :count).by(1)
    end

    scenario "adding existing master quote items", :js => true do
      expect{
        sign_in @admin
        visit new_master_quote_path

        within("#master-quote-form") do
          # click_on 'Add Master Quote Items'
          page.execute_script("$('#modal-master-quote-items').show()")

          click_on "master-quote-item-#{@master_quote_item.id}"

          page.execute_script("$('#modal-master-quote-items').hide()")

          select('TYPE1', :from => 'master_quote_master_quote_type_id')
          fill_in 'master_quote_name', :with => "Test Master Quote 2"

          click_on 'Create'
        end

        expect(current_path).to eq master_quote_path(MasterQuote.last)
        expect(MasterQuote.last.items).to eq [@master_quote_item]

      }.to change(MasterQuoteItem, :count).by(0)
    end
  end

  feature "viewing master quotes" do
    scenario "only admin can view master quotes", :js => true do
      sign_in @admin

      visit master_quotes_path
      expect(page).to have_content 'MASTER-QUOTE-1'
    end

    scenario "supplier, service provider, customer, quote_customer can NOT view master quotes" do

      [ @supplier, @service_provider, @customer, @quote_customer].each do |user|
        sign_in user
        visit master_quotes_path

        expect(page).to have_content 'You are not authorized to access this page.'
        sign_out
      end
    end
  end

  feature "updating master quotes" do
    scenario "updates master quote items for all master quotes" do
      item = create(:master_quote_item)
      master_quote_1 = create(:master_quote, name: "MASTER-1", items: [item])
      master_quote_2 = create(:master_quote, name: "MASTER-2", items: [item])

      expect(master_quote_1.items.first.description).to eq item.description
      expect(master_quote_2.items.first.description).to eq item.description

      item.description = "New Description"
      item.save

      expect(master_quote_1.items.first.description).to eq "New Description"
      expect(master_quote_2.items.first.description).to eq "New Description"
    end
  end

  feature "duplicating master quotes" do
    scenario "creates new duplicate master quote", :js => true do
      sign_in @admin
      visit master_quote_path(@master_quote_1)

      click_on "duplicate-btn"
      expect(page).to have_content "#{@master_quote_1.name} duplicated."
    end
  end

  feature "creating quote from master" do
    scenario "builds new quote and quote items", :js => true do
      # This feature requires at least one quote in system - create quote
      create(:quote)
      @master_quote_1.items << create(:master_quote_item, name: 'CV joint')
      @master_quote_1.update(vehicle_make: "toy", vehicle_model: "car", name: "test master quote")

      sign_in @admin
      visit master_quote_path(@master_quote_1)

      click_on "New Quote"
      # select(@customer.name, :from => 'customer_select')
      find("#customer_select").find(:xpath, 'option[2]').select_option
      click_on "Create Quote"

      expect(page).to_not have_content "There was a problem creating a quote from master quote"
      expect(page).to have_content "Quote created from master quote #{@master_quote_1.name}"
      expect(page).to have_xpath("//input[@value='#{@master_quote_1.items.first.name}']")
      # expect(page).to have_xpath("//textarea[@value='#{@master_quote_1.items.first.description}']")
      expect(page).to have_xpath("//input[@value='#{@master_quote_1.items.first.cost}']")

      within("#quote_tag_list_tagsinput") do
        expect(page).to have_content @master_quote_1.vehicle_make
        expect(page).to have_content @master_quote_1.vehicle_model
        expect(page).to have_content @master_quote_1.name
        expect(page).to have_content @master_quote_1.type.name
        expect(page).to have_content @master_quote_1.transmission_type
      end
    end
  end
end
