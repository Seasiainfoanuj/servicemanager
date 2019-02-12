json.array!(@po_request_uploads) do |po_request_upload|
  json.po_request_id po_request_upload.po_request_id
  json.name po_request_upload.upload_file_name
  json.size po_request_upload.upload_file_size
  json.url po_request_upload.upload.url(:original)
  json.thumbnail_url po_request_upload.upload.url(:medium)
  json.delete_url po_request_upload_path(po_request_upload)
  json.delete_type "DELETE"
end
