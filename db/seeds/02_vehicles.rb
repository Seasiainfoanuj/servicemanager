#VehicleMake.delete_all
VehicleMake.create(:id => 1, :name => "Toyota")
VehicleMake.create(:id => 2, :name => "Ford")
VehicleMake.create(:id => 3, :name => "Iveco")
puts "#{VehicleMake.count} VehicleMakes loaded"

#VehicleModel.delete_all
VehicleModel.create(id: 3, vehicle_make_id: 1, name: "Commuter", number_of_seats: 22, daily_rate_cents: 8500, license_type: 'MR')
VehicleModel.create(id: 4, vehicle_make_id: 1, name: "Coaster", number_of_seats: 18, daily_rate_cents: 8200, license_type: 'MR')
VehicleModel.create(id: 5, vehicle_make_id: 2, name: "Falcon", number_of_seats: 8, daily_rate_cents: 8900, license_type: 'MR')
VehicleModel.create(id: 6, vehicle_make_id: 3, name: "Transit", number_of_seats: 20, daily_rate_cents: 8000, license_type: 'MR')
puts "#{VehicleModel.count} VehicleModels loaded"

# Stock.delete_all
supplier = Supplier.first
Stock.create(:vehicle_model_id => 6, :stock_number => "321", :supplier_id => supplier.id)
Stock.create(:vehicle_model_id => 5, :stock_number => "645", :supplier_id => supplier.id)
Stock.create(:vehicle_model_id => 1, :stock_number => "763", :supplier_id => supplier.id)
puts "#{Stock.count} Stocks loaded"

owners = User.contact
# Vehicle.delete_all
Vehicle.create(:vehicle_model_id => 3, :vehicle_number => "01", :seating_capacity => 12, :vin_number => "09875645234243111", :owner_id => owners[0])
Vehicle.create(:vehicle_model_id => 3, :vehicle_number => "02", :seating_capacity => 12, :vin_number => "89657463452345222", :owner_id => owners[1])
Vehicle.create(:vehicle_model_id => 6, :vehicle_number => "03", :seating_capacity => 3, :vin_number => "86775645633234333", :owner_id => owners[2])
Vehicle.create(:vehicle_model_id => 3, :vehicle_number => "04", :seating_capacity => 12, :vin_number => "86784352343535444", :owner_id => owners[3])
puts "#{Vehicle.count} Vehicles loaded"

# HireVehicle.delete_all
HireVehicle.create(:vehicle_id => 1, :active => true, :daily_rate => 180, :daily_km_allowance => 200, :excess_km_rate => 1.20)
HireVehicle.create(:vehicle_id => 2)
HireVehicle.create(:vehicle_id => 3)
HireVehicle.create(:vehicle_id => 4)
puts "#{HireVehicle.count} HireVehicles loaded"

