Mailgun.configure do |config|
  config.api_key = ENV["MAILGUN_API_KEY"]
  config.domain  = 'bus4x4group.com'
end
