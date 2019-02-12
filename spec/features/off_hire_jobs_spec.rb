require "spec_helper"

feature "Off Hire Job management" do

  background do
    @admin = create(:user, :admin)
    @service_provider1 = create(:user, :service_provider)
    @service_provider2 = create(:user, :service_provider)
    @service_provider3 = create(:user, :service_provider)
    @vehicle1 = create(:vehicle)
    @vehicle2 = create(:vehicle)

    @off_hire_report1 = create(:off_hire_report)
    @hire_agreement1 = create(:hire_agreement, vehicle: @vehicle1, off_hire_report: @off_hire_report1)

    @off_hire_job1 = create(:off_hire_job, uid: "HJ-10000", status: "confirmed")
    @off_hire_job2 = create(:off_hire_job, uid: "HJ-10001", status: "confirmed",
      service_provider: @service_provider1, off_hire_report: @off_hire_report1)
    @off_hire_job3 = create(:off_hire_job, uid: "HJ-10002", service_provider: @service_provider2, off_hire_report: @off_hire_report1)
  end

  context "viewing off hire jobs" do
    scenario "admin can view all off hire jobs", :js => true do
      sign_in @admin
      visit off_hire_jobs_path

      expect(page).to have_content 'HJ-10000'
      expect(page).to have_content 'HJ-10001'
      expect(page).to have_content 'HJ-10002'

      visit off_hire_job_path(@off_hire_job1)

      within (".page-header") do
        expect(page).to have_content @off_hire_job1.uid
      end

      visit off_hire_job_path(@off_hire_job2)

      within (".page-header") do
        expect(page).to have_content @off_hire_job2.uid
      end

      visit off_hire_job_path(@off_hire_job3)

      within (".page-header") do
        expect(page).to have_content @off_hire_job3.uid
      end
    end

    scenario "service provider can view limited off hire jobs", :js => true do
      sign_in @service_provider1
      visit off_hire_jobs_path

      expect(page).to_not have_content 'HJ-10000'
      expect(page).to have_content 'HJ-10001'
      expect(page).to_not have_content 'HJ-10002'

      visit off_hire_job_path(@off_hire_job1)
      expect(page).to have_content 'You are not authorized to access this page.'

      visit off_hire_job_path(@off_hire_job2)
      within (".page-header") do
        expect(page).to have_content "#{@off_hire_job2.uid}"
      end

      visit off_hire_job_path(@off_hire_job3)
      expect(page).to have_content 'You are not authorized to access this page.'
    end

    scenario "can be filtered by vehicle", js: true do
      sign_in @admin
      visit off_hire_jobs_path

      expect(page).to have_content @vehicle1.vehicle_number

      visit vehicle_off_hire_jobs_path(@vehicle1)
      within(".page-header") do
        expect(page).to have_content @vehicle1.vehicle_number
      end

      within("tbody") do
        expect(page).to have_content @vehicle1.vehicle_number
        expect(page).to_not have_content @vehicle2.vehicle_number
      end
    end

    scenario "can be filtered by user", :js => true do
      sign_in @admin
      visit off_hire_jobs_path

      within("tbody") do
        expect(page).to have_content @off_hire_job2.uid
        expect(page).to have_content @off_hire_job3.uid
      end

      visit user_off_hire_jobs_path(@service_provider1)
      expect(page.status_code).to eq 200

      within("tbody") do
        expect(page).to have_content @off_hire_job2.uid
        expect(page).to_not have_content @off_hire_job3.uid
      end
    end
  end

   context "completing off hire jobs" do
    scenario "admin can complete off hire jobs", :js => true do
      sign_in @admin
      visit off_hire_job_path(@off_hire_job1)

      within (".page-header") do
        expect(page).to have_content "Complete"
        click_on "Complete"
      end

      expect(current_path).to eq off_hire_job_complete_step1_path(@off_hire_job1)

      within (".page-header") do
        expect(page).to have_content "Next"
        click_on "Next"
      end

      within (".page-header") do
        expect(page).to have_content "Submit & Finish"
      end

      expect(page).to_not have_content 'You are not authorized to access this page.'
    end

    scenario "service_provider can complete off hire jobs", :js => true do
      sign_in @service_provider1
      visit off_hire_job_complete_step1_path(@off_hire_job2)

      expect(current_path).to eq off_hire_job_complete_step1_path(@off_hire_job2)
      expect(page).to_not have_content 'You are not authorized to access this page.'
    end

  end
end
