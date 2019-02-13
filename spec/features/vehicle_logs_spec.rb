require "spec_helper"

feature "Vehicle Logs" do
  background do
    @admin = create(:user, :admin)
    @service_provider1 = create(:user, :service_provider)
    @service_provider2 = create(:user, :service_provider)
    @vehicle_log1 = create(:vehicle_log, service_provider: @service_provider1, uid: 'LOG-AB1000')
    @vehicle_log2 = create(:vehicle_log, service_provider: @service_provider2, uid: 'LOG-AB1001')
  end

  feature "viewing vehicle logs" do
    scenario "can be filtered by user", :js => true do
      sign_in @admin
      visit vehicle_logs_path

      within("tbody") do
        expect(page).to have_content @vehicle_log1.uid
        expect(page).to have_content @vehicle_log2.uid
      end

      visit user_vehicle_logs_path(@service_provider1)
      expect(page.status_code).to eq 200

      within("tbody") do
        expect(page).to have_content @vehicle_log1.uid
        expect(page).to_not have_content @vehicle_log2.uid
      end
    end
  end
end
