json.array!([@quote_specification_sheet]) do |specification_sheet|
  json.quote_id specification_sheet.quote_id
  json.name specification_sheet.upload_file_name
  json.size specification_sheet.upload_file_size
  json.url specification_sheet.upload.url(:original)
  json.thumbnail_url specification_sheet.upload.url(:medium)
  json.delete_url quote_specification_sheet_path(specification_sheet.quote, specification_sheet)
  json.delete_type "DELETE"
end
