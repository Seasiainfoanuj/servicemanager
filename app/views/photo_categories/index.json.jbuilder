json.array!(@photo_categories) do |photo_category|
  json.id photo_category.id
  json.name photo_category.name
end