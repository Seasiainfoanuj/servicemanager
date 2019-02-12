json.array!(@uploads) do |upload|
  json.sales_order_id upload.sales_order_id
  json.name upload.upload_file_name
  json.size upload.upload_file_size
  json.url upload.upload.url(:original)
  json.thumbnail_url upload.upload.url(:medium)
  json.delete_url sales_order_upload_path(upload)
  json.delete_type "DELETE"
end
