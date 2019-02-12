json.array!(@file_uploads) do |file_upload|
  json.name file_upload.upload_file_name
  json.size file_upload.upload_file_size
  json.url file_upload.upload.url(:original)
  json.thumbnail_url file_upload.upload.url(:medium)
  json.delete_url file_upload_path(file_upload)
  json.delete_type "DELETE"
end