json.array!(@vehicles) do |vehicle|
  json.id vehicle.id
  json.name vehicle.name
  json.number vehicle.number
  json.vin_number vehicle.vin_number
  json.transmission vehicle.transmission
  json.seating_capacity vehicle.seating_capacity
  json.location vehicle.location
  json.daily_rate vehicle.hire_details.daily_rate
  json.daily_km_allowance vehicle.hire_details.daily_km_allowance
  json.excess_km_rate vehicle.hire_details.excess_km_rate
end
