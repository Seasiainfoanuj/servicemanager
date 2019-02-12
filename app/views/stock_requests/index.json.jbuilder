json.array!(@stock_requests) do |stock_request|
  json.extract! stock_request, :id, :invoice_company_id, :supplier_id, :customer_id, :vehicle_make, :vehicle_model, :transmission_type, :requested_delivery_date, :details
  json.url stock_request_url(stock_request, format: :json)
end
