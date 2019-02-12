json.array!(@workorder_type_uploads) do |workorder_type_upload|
  json.workorder_type_id workorder_type_upload.workorder_type_id
  json.name workorder_type_upload.upload_file_name
  json.size workorder_type_upload.upload_file_size
  json.url workorder_type_upload.upload.url(:original)
  json.thumbnail_url workorder_type_upload.upload.url(:medium)
  json.delete_url workorder_type_upload_path(workorder_type_upload)
  json.delete_type "DELETE"
end