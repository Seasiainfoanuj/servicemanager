json.array!(@log_uploads) do |log_upload|
  json.vehicle_log_id log_upload.vehicle_log_id
  json.name log_upload.upload_file_name
  json.size log_upload.upload_file_size
  json.url log_upload.upload.url(:original)
  json.thumbnail_url log_upload.upload.url(:medium)
  json.delete_url log_upload_path(log_upload)
  json.delete_type "DELETE"
end