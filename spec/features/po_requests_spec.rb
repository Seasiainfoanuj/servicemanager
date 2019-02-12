require "spec_helper"

feature "Po Request" do
  scenario "Links vehicle if vin number matches" do
    vehicle = create(:vehicle)
    po_request = create(:po_request, vehicle_vin_number: vehicle.vin_number)
    expect(po_request.vehicle).to eq vehicle
  end
end
