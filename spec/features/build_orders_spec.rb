require "spec_helper"

feature "Build Orders" do
  background do
    @admin1 = create(:user, :admin, first_name: 'Barry', last_name: 'Baumer', client_attributes: { client_type: 'person'})
    @admin2 = create(:user, :admin, first_name: 'Larry', last_name: 'Lonsdale', client_attributes: { client_type: 'person'})
    @service_provider1 = create(:user, :service_provider, client_attributes: { client_type: 'person'})
    @customer1 = create(:user, :customer, client_attributes: { client_type: 'person'})
    @invoice_company = create(:invoice_company, name: 'ABC Limited')
    vehicle = create(:vehicle)
    @build_order1 = build(:build_order, uid: "BO-10000", manager: @admin1, service_provider: @service_provider1, invoice_company: @invoice_company)
    @build_order2 = build(:build_order, uid: "BO-10001", manager: @admin2, invoice_company: @invoice_company)
    @build = create(:build, vehicle: vehicle, invoice_company: @invoice_company, build_orders: [@build_order1, @build_order2])
  end

  feature "viewing build orders" do
    scenario "can be filtered by user", js: true do
      sign_in @admin1
      visit build_orders_path

      within("tbody") do
        expect(page).to have_content @build_order1.uid
        expect(page).to have_content @build_order2.uid
      end

      visit user_build_orders_path(@admin1)
      expect(page.status_code).to eq 200

      within("tbody") do
        expect(page).to have_content @build_order1.uid
        expect(page).to_not have_content @build_order2.uid
      end
    end

    scenario "admin can view all build orders", :js => true do
      sign_in @admin1
      visit build_orders_path

      within("tbody") do
        expect(page).to have_content @build_order1.uid
        expect(page).to have_content @build_order2.uid
      end
    end
    scenario "service provider can view limited build orders", :js => true  do
      sign_in @service_provider1
      visit build_orders_path

      within("tbody") do
        expect(page).to have_content @build_order1.uid
        expect(page).to_not have_content @build_order2.uid
      end
    end
    scenario "customer can view subscribed build orders", :js => true  do
      build_order = create(:build_order, build: @build)
      build_order.subscribers << @customer1
      build_order.save

      sign_in @customer1
      visit build_orders_path

      within("tbody") do
        expect(page).to have_content build_order.uid
        expect(page).to_not have_content @build_order1.uid
        expect(page).to_not have_content @build_order2.uid
      end
    end
  end

  feature "creating build orders" do
    scenario "admin can create build orders", :js => true do
      sign_in @admin1

      visit new_build_order_path(build_id: @build.id)

      expect(page).to have_content "Create Build Order"

      fill_in 'build_order_name', with: "Test Build Order"
      within('.invoice-company-details') do
        select 'ABC Limited', from: 'build_order_invoice_company_id'
      end
      select @service_provider1.company_name, from: 'service_provider_select'
      within "#build-order-assign-to" do
        select 'Larry Lonsdale', from: "admin-select"
      end
      fill_in 'build_order_sched_date_field', with: '01/01/2200'
      fill_in 'build_order_etc_date_field', with: '01/01/2300'
      count_start = BuildOrder.count
      within ('.page-header') do
        click_link 'Create Build Order'
      end
      count_end = BuildOrder.count
      expect(count_end - count_start).to eq(1)
    end
    
    scenario "service provider can NOT create build orders" do
      sign_in @service_provider1

      visit new_build_order_path(build_id: @build.id)

      expect(page).to have_content 'You are not authorized to access this page.'
    end
    scenario "customer can NOT create build orders" do
      sign_in @customer1

      visit new_build_order_path(build_id: @build.id)

      expect(page).to have_content 'You are not authorized to access this page.'
    end
  end

  feature "completing build orders" do
    scenario "admin can complete build orders" do
      sign_in @admin1
      visit build_order_complete_step1_path(@build_order1)

      within (".page-header") do
        expect(page).to have_content "Next"
      end

      expect(current_path).to eq build_order_complete_step1_path(@build_order1)
      expect(page).to_not have_content 'You are not authorized to access this page.'
    end
    scenario "service provider can complete limited build orders" do
      sign_in @service_provider1
      visit build_order_complete_step1_path(@build_order1)

      within (".page-header") do
        expect(page).to have_content "Next"
      end

      expect(current_path).to eq build_order_complete_step1_path(@build_order1)
      expect(page).to_not have_content 'You are not authorized to access this page.'

      visit build_order_complete_step1_path(@build_order2)
      expect(page).to have_content 'You are not authorized to access this page.'
    end
    scenario "customer can NOT complete build orders" do
      sign_in @customer1

      visit build_order_complete_step1_path(@build_order1)

      expect(page).to have_content 'You are not authorized to access this page.'
    end
  end

# TODO: failing: Couldn't find BuildOrder with id=1
  # feature "notification email" do
  #   scenario "sent to delayed job", :js => true do
  #     sign_in @admin1

  #     visit build_order_path(@build_order1)
  #     within ".page-header" do
  #       click_on "Send by Email"
  #     end

  #     find(:xpath, "(//ins)[2]").click
  #     expect {
  #       click_on "Send"
  #       sleep(0.2)
  #     }.to change(Delayed::Job, :count).by(1)
  #   end
  # end
end
