json.array!(@enquiries) do |enquiry|
  json.extract! enquiry, :id, :enquiry_type_id, :user_id,:score, :manager_id, :uid, :first_name, :last_name, :email, :phone, :company, :job_title, :details
  json.url enquiry_url(enquiry, format: :json)
end
