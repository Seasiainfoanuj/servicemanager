require "asset_sync"

AssetSync.configure do |config|
  config.enabled = !Rails.env.development?
  config.fog_provider = 'AWS'
  config.fog_directory = ENV['AWS_S3_BUCKET']
  config.aws_iam_roles = true

  # Increase upload performance by configuring your region
  config.fog_region = ENV['AWS_S3_REGION']
  #
  # Don't delete files from the store
  config.existing_remote_files = "keep"

  # If Webpacker is installed,
  # add its output path to upload the packs too.
  # config.add_local_file_paths do
  #   public_root = Rails.root.join("public")
  #   Dir.chdir(public_root) do
  #     packs_dir = Webpacker.config.public_output_path.relative_path_from(public_root)
  #     Dir[File.join(packs_dir, '/**/**')]
  #   end
  # end
end
