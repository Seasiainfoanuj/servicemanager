json.array!(@hire_uploads) do |hire_upload|
  json.hire_agreement_id hire_upload.hire_agreement_id
  json.name hire_upload.upload_file_name
  json.size hire_upload.upload_file_size
  json.url hire_upload.upload.url(:original)
  json.thumbnail_url hire_upload.upload.url(:medium)
  json.delete_url hire_upload_path(hire_upload)
  json.delete_type "DELETE"
end