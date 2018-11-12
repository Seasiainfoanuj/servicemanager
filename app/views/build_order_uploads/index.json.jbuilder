json.array!(@build_order_uploads) do |build_order_upload|
  json.build_order_id build_order_upload.build_order_id
  json.name build_order_upload.upload_file_name
  json.size build_order_upload.upload_file_size
  json.url build_order_upload.upload.url(:original)
  json.thumbnail_url build_order_upload.upload.url(:medium)
  json.delete_url build_order_upload_path(build_order_upload)
  json.delete_type "DELETE"
end