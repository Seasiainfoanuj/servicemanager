json.array!(@document_types) do |document_type|
  json.id document_type.id
  json.name document_type.name
end