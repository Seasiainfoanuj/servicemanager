json.array!(@workorder_uploads) do |workorder_upload|
  json.workorder_id workorder_upload.workorder_id
  json.name workorder_upload.upload_file_name
  json.size workorder_upload.upload_file_size
  json.url workorder_upload.upload.url(:original)
  json.thumbnail_url workorder_upload.upload.url(:medium)
  json.delete_url workorder_upload_path(workorder_upload)
  json.delete_type "DELETE"
end