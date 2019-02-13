json.array!(@customers) do |user|
  json.name user.name
  json.id user.id
  json.dob user.dob_field
  if user.licence.present?
    json.licence do |licence|
      json.number user.licence.number
      json.state_of_issue user.licence.state_of_issue
      json.expiry_date user.licence.expiry_date_field
    end
  end
end
