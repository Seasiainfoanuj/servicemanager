require "spec_helper"

feature "Hire agreement management" do
  background do
    @admin = create(:user, :admin)

    @customer1 = create(:user, :customer)
    @customer2 = create(:user, :customer)

    @service_provider1 = create(:user, :service_provider)

    @supplier = create(:user, :supplier)
    @quote_customer = create(:user, :quote_customer)

    @vehicle1 = create(:vehicle)
    @hire_agreement1 = create(:hire_agreement, customer: @customer1, uid: 'HI-AB1000')
    @hire_agreement2 = create(:hire_agreement, customer: @customer2, uid: 'HI-AB1001', vehicle: @vehicle1)
    @hire_agreement3 = create(:hire_agreement, customer: @service_provider1, uid: 'HI-AB1002')
  end

  context "viewing hire agreements" do
    scenario "admin can view all hire agreements", :js => true do
      sign_in @admin
      visit hire_agreements_path

      expect(page).to have_content 'HI-AB1000'
      expect(page).to have_content 'HI-AB1001'
      expect(page).to have_content 'HI-AB1002'

      visit hire_agreement_path(@hire_agreement1)

      within(".page-header") do
        expect(page).to have_content "#{@hire_agreement1.uid}"
      end

      visit hire_agreement_path(@hire_agreement2)

      within(".page-header") do
        expect(page).to have_content "#{@hire_agreement2.uid}"
      end
    end

    scenario "service provider can view limited hire agreements", :js => true do
      sign_in @service_provider1
      visit hire_agreements_path

      expect(page).to_not have_content 'HI-AB1000'
      expect(page).to_not have_content 'HI-AB1001'
      expect(page).to have_content 'HI-AB1002'

      visit hire_agreement_path(@hire_agreement1)

      expect(page).to have_content 'You are not authorized to access this page.'

      visit hire_agreement_path(@hire_agreement3)

      within(".page-header") do
        expect(page).to have_content @hire_agreement3.uid
      end
    end

    scenario "customer can view limited hire agreements", :js => true do
      sign_in @customer2
      visit hire_agreements_path


      expect(page).to_not have_content 'HI-AB1000'
      expect(page).to have_content 'HI-AB1001'
      expect(page).to_not have_content 'HI-AB1002'

      visit hire_agreement_path(@hire_agreement1)

      expect(page).to have_content 'You are not authorized to access this page.'

      visit hire_agreement_path(@hire_agreement2)

      within(".page-header") do
        expect(page).to have_content @hire_agreement2.uid
      end

      visit hire_agreement_path(@hire_agreement3)

      expect(page).to have_content 'You are not authorized to access this page.'
    end

    scenario "can be filtered by vehicle", :js => true do
      sign_in @admin
      visit hire_agreements_path

      within("tbody") do
        expect(page).to have_content @hire_agreement1.uid
        expect(page).to have_content @hire_agreement2.uid
      end

      visit vehicle_hire_agreements_path(@vehicle1)
      expect(page.status_code).to eq 200

      within("tbody") do
        expect(page).to_not have_content @hire_agreement1.uid
        expect(page).to have_content @hire_agreement2.uid
      end
    end

    scenario "can be filtered by user", :js => true do
      sign_in @admin
      visit hire_agreements_path

      within("tbody") do
        expect(page).to have_content @hire_agreement1.uid
        expect(page).to have_content @hire_agreement2.uid
      end

      visit user_hire_agreements_path(@customer1)
      expect(page.status_code).to eq 200

      within("tbody") do
        expect(page).to have_content @hire_agreement1.uid
        expect(page).to_not have_content @hire_agreement2.uid
      end
    end
  end

  context "creating hire agreements" do
    scenario "only admin can create a hire agreement", :js => true do
      sign_in @admin
      visit hire_agreements_path

      within(".page-header") do
        click_on 'New Hire Agreement'
      end
      click_on 'Existing Customer'

      expect(page).to have_content 'Hire Agreement Type'
      expect(page).to have_content 'Next'

      sign_out

      # sign_in @supplier
      # visit new_hire_agreement_path
      # expect(page).to have_content 'You are not authorized to access this page.'

      # sign_out

      # sign_in @service_provider1
      # visit new_hire_agreement_path
      # expect(page).to have_content 'You are not authorized to access this page.'

      # sign_out

      # sign_in @customer1
      # visit new_hire_agreement_path
      # expect(page).to have_content 'You are not authorized to access this page.'

      # sign_out

      # sign_in @quote_customer
      # visit new_hire_agreement_path
      # expect(page).to have_content 'You are not authorized to access this page.'

    end
  end
end
