json.array!(@vehicles) do |vehicle|
  json.name vehicle.hire_resource
  json.id vehicle.id
end