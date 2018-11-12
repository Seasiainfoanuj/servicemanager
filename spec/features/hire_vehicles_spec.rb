require "spec_helper"

feature "Hire vehicle management" do
  background do
    @admin = create(:user, :admin)
    @supplier = create(:user, :supplier)
    @customer = create(:user, :customer)

    @hire_vehicle1 = create(:hire_vehicle, vehicle_id: @vehicle1.id)
    @hire_vehicle2 = create(:hire_vehicle, vehicle_id: @vehicle2.id)
    @hire_vehicle3 = create(:hire_vehicle, vehicle_id: @vehicle3.id)
  end
end
