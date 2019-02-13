json.array!(@hire_agreement_type_uploads) do |upload|
  json.hire_agreement_type_id upload.hire_agreement_type_id
  json.name upload.upload_file_name
  json.size upload.upload_file_size
  json.url upload.upload.url(:original)
  json.thumbnail_url upload.upload.url(:medium)
  json.delete_url hire_agreement_type_upload_path(upload)
  json.delete_type "DELETE"
end