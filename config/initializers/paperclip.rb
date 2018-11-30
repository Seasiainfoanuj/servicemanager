if Rails.env.staging? || Rails.env.production?
  Paperclip::Attachment.default_options.merge!(
    storage: :fog,
    fog_credentials: {
      use_iam_profile: true,
      provider: 'AWS',
      region: ENV['AWS_S3_REGION'] || 'ap-southeast-2'
    },
    path: "/uploads/:class/:attachment/:id_partition/:style/:filename",
    fog_directory: ENV['AWS_S3_BUCKET'],
    fog_public: true,
    fog_host: ENV['RAILS_ASSET_HOST']
  )
else
  Paperclip::Attachment.default_options[:use_timestamp] = false
end
