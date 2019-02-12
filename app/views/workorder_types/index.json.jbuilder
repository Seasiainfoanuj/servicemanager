json.array!(@workorder_types) do |workorder_type|
  json.id workorder_type.id
  json.name workorder_type.name
  json.notes workorder_type.notes
end