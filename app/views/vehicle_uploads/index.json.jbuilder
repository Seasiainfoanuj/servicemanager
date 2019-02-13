json.array!(@vehicle_uploads) do |vehicle_upload|
  json.vehicle_id vehicle_upload.vehicle_id
  json.name vehicle_upload.upload_file_name
  json.size vehicle_upload.upload_file_size
  json.url vehicle_upload.upload.url(:original)
  json.thumbnail_url vehicle_upload.upload.url(:medium)
  json.delete_url vehicle_upload_path(vehicle_upload)
  json.delete_type "DELETE"
end