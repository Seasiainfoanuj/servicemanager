json.array!(@off_hire_job_uploads) do |upload|
  json.off_hire_job_id upload.off_hire_job_id
  json.name upload.upload_file_name
  json.size upload.upload_file_size
  json.url upload.upload.url(:original)
  json.thumbnail_url upload.upload.url(:medium)
  json.delete_url off_hire_job_upload_path(upload)
  json.delete_type "DELETE"
end