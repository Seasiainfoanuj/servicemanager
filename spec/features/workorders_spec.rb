require "spec_helper"

feature "Workorder management" do

  background do
    @admin = create(:user, :admin, client_attributes: { client_type: 'person'})
    @admin2 = create(:user, :admin, client_attributes: { client_type: 'person'})
    @service_provider1 = create(:user, :service_provider, client_attributes: { client_type: 'person'})
    @service_provider2 = create(:user, :service_provider, client_attributes: { client_type: 'person'})
    @service_provider3 = create(:user, :service_provider, client_attributes: { client_type: 'person'})
    @customer = create(:user, :customer, client_attributes: { client_type: 'person'})
    @customer2 = create(:user, :customer, email: 'lisa.moore@example.com', client_attributes: { client_type: 'person'})
    @vehicle1 = create(:vehicle, owner: @customer2)
    @vehicle2 = create(:vehicle, owner: @customer2)
    @vehicle3 = create(:vehicle, owner: @customer2)

    @workorder1 = create(:workorder, uid: "WO-10000", status: "confirmed", is_recurring: true, vehicle: @vehicle1)
    @workorder2 = create(:workorder, uid: "WO-10001", status: "confirmed",
      service_provider: @service_provider1, customer: nil, vehicle: @vehicle2)
    @workorder3 = create(:workorder, uid: "WO-10002", service_provider: @service_provider2,
      customer: @customer, vehicle: @vehicle3)
  end

  context "viewing workorders" do
    scenario "admin can view all workorders", :js => true do
      sign_in @admin
      visit workorders_path

      expect(page).to have_content 'WO-10000'
      expect(page).to have_content 'WO-10001'
      expect(page).to have_content 'WO-10002'

      visit workorder_path(@workorder1)
      within (".page-header") do
        expect(page).to have_content "#{@workorder1.uid}"
      end

      visit workorder_path(@workorder2)

      within (".page-header") do
        expect(page).to have_content "#{@workorder2.uid}"
      end

      visit workorder_path(@workorder3)

      within (".page-header") do
        expect(page).to have_content "#{@workorder3.uid}"
      end
    end

    scenario "service provider can view limited workorders", :js => true do
      sign_in @service_provider1
      visit workorders_path

      expect(page).to_not have_content 'WO-10000'
      expect(page).to have_content 'WO-10001'
      expect(page).to_not have_content 'WO-10002'

      visit workorder_path(@workorder1)
      expect(page).to have_content 'You are not authorized to access this page.'

      visit workorder_path(@workorder2)
      within (".page-header") do
        expect(page).to have_content "#{@workorder2.uid}"
      end

      visit workorder_path(@workorder3)
      expect(page).to have_content 'You are not authorized to access this page.'
    end

    scenario "customer can view limited workorders", :js => true do
      sign_in @customer
      visit workorders_path

      expect(page).to_not have_content 'WO-10000'
      expect(page).to_not have_content 'WO-10001'
      expect(page).to have_content 'WO-10002'

      visit workorder_path(@workorder1)
      expect(current_path).to eq root_path
      expect(page).to have_content 'You are not authorized to access this page.'

      visit workorder_path(@workorder2)
      expect(current_path).to eq root_path
      expect(page).to have_content 'You are not authorized to access this page.'

      visit workorder_path(@workorder3)
      within (".page-header") do
        expect(page).to have_content "#{@workorder3.uid}"
      end

    end

    scenario "can be filtered by vehicle", js: true do
      sign_in @admin
      visit workorders_path

      expect(page).to have_content @vehicle2.vehicle_number

      visit vehicle_workorders_path(@vehicle1.id)
      within(".page-header") do
        expect(page).to have_content @vehicle1.vehicle_number
      end

      within("tbody") do
        expect(page).to have_content @vehicle1.vehicle_number
        expect(page).to_not have_content @vehicle2.vehicle_number
      end
    end

    scenario "can be filtered by user", js: true do
      sign_in @admin
      visit workorders_path

      within("tbody") do
        expect(page).to have_content @workorder1.uid
        expect(page).to have_content @workorder2.uid
        expect(page).to have_content @workorder3.uid
      end

      visit user_workorders_path(@service_provider1)
      expect(page.status_code).to eq 200

      within("tbody") do
        expect(page).to_not have_content @workorder1.uid
        expect(page).to have_content @workorder2.uid
        expect(page).to_not have_content @workorder3.uid
      end
    end
  end

  context "creating workorders" do
    scenario "admin can create workorders" do
      sign_in @admin
      visit new_workorder_path

      expect(page).to have_content 'Create Workorder'
    end
    scenario "service provider can NOT create workorders" do
      sign_in @service_provider1

      visit new_workorder_path

      expect(page).to have_content 'You are not authorized to access this page.'
    end
    scenario "customer can NOT create workorders" do
      sign_in @customer
      visit new_workorder_path

      expect(current_path).to eq root_path
      expect(page).to have_content 'You are not authorized to access this page.'
    end
  end

  context "completing workorders" do
    scenario "admin can complete workorder" do
      sign_in @admin
      visit workorder_complete_step1_path(@workorder1)

      within (".page-header") do
        expect(page).to_not have_content "Complete"
        expect(page).to have_content "Next"
      end

      expect(current_path).to eq workorder_complete_step1_path(@workorder1)
      expect(page).to_not have_content 'You are not authorized to access this page.'
    end

    scenario "service_provider can complete workorder" do
      sign_in @service_provider1
      visit workorder_complete_step1_path(@workorder2)

      expect(current_path).to eq workorder_complete_step1_path(@workorder2)
      expect(page).to_not have_content 'You are not authorized to access this page.'
    end

    scenario "customer can NOT complete workorder" do
      sign_in @customer
      visit workorder_complete_step1_path(@workorder2)

      expect(current_path).to eq root_path
      expect(page).to have_content 'You are not authorized to access this page.'
    end

    feature "recurring workorders" do
      context "when workorder is recurring" do
        scenario "create next workorder" do
          sign_in @admin
          count_start = Workorder.count
          visit workorder_complete_step1_path(@workorder1, create_recurring_workorder: true)
          count_end = Workorder.count
          expect(count_end).to eq(count_start + 1)
          expect(Workorder.all[0].status).to eq("complete")
          expect(Workorder.all[1].status).to eq("confirmed")
        end
      end

      context "when workorder is NOT recurring" do
        scenario "dont create workorder" do
          sign_in @admin

          expect {
            visit workorder_complete_step1_path(@workorder1)
          }.to change(Workorder, :count).by(0)
        end
      end
    end

    feature "vehicle odometer_reading gets updated" do
      context "if odometer_reading is >= vehicle odometer_reading" do
        scenario "updates vehicle odometer_reading", :js => true do
          vehicle = create(:vehicle, odometer_reading: 800)
          workorder = create(:workorder, uid: "WO-10003", service_provider: @service_provider3,
            customer: @customer, vehicle: vehicle)

          sign_in @service_provider3
          visit workorder_complete_step1_path(workorder)

          within("#complete-form") do
            fill_in 'odometer_reading', :with => 900
          end

          within(".page-header") do
            click_on "Next"
          end

          expect(page).to have_content 'Vehicle odometer reading updated.'
          expect(workorder.vehicle_log.vehicle.odometer_reading.to_i).to eq 900
        end
      end

      context "if odometer_reading is < vehicle odometer_reading" do
        scenario "does not update vehicle odometer_reading" do
          vehicle = create(:vehicle, odometer_reading: 800)
          workorder = create(:workorder, uid: "WO-10003", service_provider: @service_provider3,
            customer: @customer, vehicle: vehicle)

          sign_in @service_provider3
          visit workorder_complete_step1_path(workorder)

          within("#complete-form") do
            fill_in 'odometer_reading', :with => 300
          end

          within(".page-header") do
            click_on "Next"
          end

          expect(page).to_not have_content 'Vehicle odometer reading updated.'
          expect(workorder.vehicle_log.vehicle.odometer_reading.to_i).to eq 800
        end
      end
    end

    feature "complete button" do
      scenario "does NOT exist for draft, complete or cancelled workorders" do
        sign_in @admin

        ['draft', 'complete', 'cancelled'].each do |status|
          @workorder1.status = status
          @workorder1.save

          visit workorder_path(@workorder1)

          within (".page-header") do
            expect(page).to_not have_content "Complete"
          end
        end
      end

      scenario "exists for confirmed workorders" do
        sign_in @admin

        @workorder1.status = "confirmed"
        @workorder1.save

        visit workorder_path(@workorder1)

        within (".page-header") do
          expect(page).to have_content "Complete"
        end
      end
    end

    scenario "mailer job sent to delayed job" do
      sign_in @admin

      expect {
        visit workorder_complete_step1_path(@workorder1)
      }.to change(Delayed::Job, :count).by(3)
    end
  end

  feature "destroying workorders" do
    scenario "only admin can destroy workorders", :js => true do
      sign_in @admin
      visit workorders_path

      expect(page).to have_css "#workorder-#{@workorder1.id}-del-btn"
      expect(page).to have_css "#workorder-#{@workorder2.id}-del-btn"

      sign_out

      sign_in @service_provider1
      visit workorders_path
      expect(page).to_not have_css "#workorder-#{@workorder1.id}-del-btn"
      expect(page).to_not have_css "#workorder-#{@workorder3.id}-del-btn"

      sign_out

      sign_in @customer
      visit workorders_path
      expect(page).to_not have_css "#workorder-#{@workorder1.id}-del-btn"
      expect(page).to_not have_css "#workorder-#{@workorder3.id}-del-btn"
    end
  end

  feature "notification email" do
    scenario "sent to delayed job", :js => true do
      sign_in @admin

      visit workorder_path(@workorder1)
      within ".page-header" do
        click_on "Send Workorder"
      end

      find(:xpath, "(//ins)[3]").click
      expect {
        click_on "Send"
        sleep(0.2)
      }.to change(Delayed::Job, :count).by(1)
    end

    feature "other email addresses" do
      scenario "displays an error when invalid emails entered", :js => true do
        sign_in @admin

        visit workorder_path(@workorder1)
        within ".page-header" do
          click_on "Send Workorder"
        end

        find(:xpath, "(//ins)[4]").click
        fill_in "other_recipients", :with => 'valid@test.com, invalid@test'
        expect {
          click_on "Send"
          sleep(0.2)
        }.to change(Delayed::Job, :count).by(0)

        expect(page).to have_content "You must select at least one recipient:"
      end

      scenario "sent to delayed job when valid emails entered", :js => true do
        sign_in @admin

        visit workorder_path(@workorder1)
        within ".page-header" do
          click_on "Send Workorder"
        end

        find(:xpath, "(//ins)[4]").click
        fill_in "other_recipients", :with => 'valid@test.com, email@test.com'
        expect {
          click_on "Send"
          sleep(0.2)
        }.to change(Delayed::Job, :count).by(2)

        expect(page).to_not have_content "You must select at least one recipient:"
      end
    end
  end
end
