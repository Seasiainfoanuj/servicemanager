json.array!(@on_hire_report_uploads) do |upload|
  json.on_hire_report_id upload.on_hire_report_id
  json.name upload.upload_file_name
  json.size upload.upload_file_size
  json.url upload.upload.url(:original)
  json.thumbnail_url upload.upload.url(:medium)
  json.delete_url on_hire_report_upload_path(upload)
  json.delete_type "DELETE"
end