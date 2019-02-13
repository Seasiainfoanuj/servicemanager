json.array!(@vehicles) do |vehicle|
  json.key vehicle.id
  json.label vehicle.resource(current_user)
end
