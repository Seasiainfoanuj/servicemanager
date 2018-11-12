json.array!(@build_uploads) do |upload|
  json.build_id upload.build_id
  json.name upload.upload_file_name
  json.size upload.upload_file_size
  json.url upload.upload.url(:original)
  json.thumbnail_url upload.upload.url(:medium)
  json.delete_url build_upload_path(upload)
  json.delete_type "DELETE"
end
