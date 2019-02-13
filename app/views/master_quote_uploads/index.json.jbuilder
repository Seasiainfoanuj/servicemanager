json.array!(@master_quote_uploads) do |upload|
  json.master_quote_id upload.master_quote_id
  json.name upload.upload_file_name
  json.size upload.upload_file_size
  json.url upload.upload.url(:original)
  json.thumbnail_url upload.upload.url(:medium)
  json.delete_url master_quote_upload_path(upload)
  json.delete_type "DELETE"
end
