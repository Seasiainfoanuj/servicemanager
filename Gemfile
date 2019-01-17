source 'https://rubygems.org'
ruby '2.3.3'

gem 'rails', '4.2.7.1'
gem 'mysql2', '~> 0.3.18'
gem 'sass-rails', '~> 5.0.6'
gem 'compass-rails', '~> 3.0.2'
gem 'uglifier', '~> 3.2.0'
gem 'coffee-rails', '~> 4.2.1'
gem 'jquery-rails', '~> 4.0.4'
gem "jquery-turbolinks", "~> 2.1"
gem 'turbolinks', '~> 5.0.0'
gem 'jquery-datatables-rails', '~> 3.3.0'
gem 'jquery-ui-rails', '~> 5.0.5'

gem 'jbuilder', '~> 2.6.4'

gem 'momentjs-rails'
gem 'ruby_dep', ' 1.3.0'
gem "listen", "~> 3.0.0"
gem 'zeroclipboard-rails', '~> 0.1.2'
gem 'twitter-bootstrap-rails', '~> 3.2.2'
gem 'bootstrap-datepicker-rails', '~> 1.6.4'
gem 'bootstrap-timepicker-rails', '~> 0.1.3'
gem 'bootstrap-daterangepicker-rails', '~> 0.1.5'
gem 'bootstrap-colorpicker-rails', '~> 0.4.0'
gem 'icheck-rails', '~> 1.0.2.2'
gem 'select2-rails', '~> 4.0.3'
gem 'chosen-rails', '1.5.2'

gem 'ckeditor_rails', '~> 4.6.2'
gem 'crummy', '~> 1.8.0'
gem 'maskedinput-rails', '1.4.1.0'
gem 'paperclip', '~> 5.1.0'
gem 'jquery-fileupload-rails', '~> 0.4.1'
gem 'jquery-validation-rails', '~> 1.16.0'
gem 'devise'
gem 'slim-rails', '3.1.1'
gem 'cancan'
gem 'role_model'
gem 'daemons'
gem 'delayed_job_active_record'
gem 'whenever', :require => false
# gem 'monetize'
gem 'money-rails'
gem 'prawn', '~> 2.2.2'
gem 'prawn-table', '~> 0.2.2'
gem 'combine_pdf', '~> 1.0.0'
gem 'wicked_pdf', '~> 1.1.0'
gem 'wkhtmltopdf-binary', '~> 0.12.3'
gem 'public_activity'
# gem 'newrelic_rpm'
gem 'touchpunch-rails', '~> 1.0.3'
gem 'will_paginate'

gem 'acts-as-taggable-on'

gem 'mailgun'
gem 'net-ssh'

# OpsCare added Gems
gem 'asset_sync'
gem 'fog-aws'
gem "ops_care", git: "git@github.com:reinteractive/OpsCare.git", branch: "master"

group :production do
  gem "unicorn"
end

group :development do
  gem 'guard-rspec'
  gem 'guard-livereload'
  gem 'guard-zeus'
  gem 'capistrano', '~> 2.15'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  # gem 'capybara-webkit'
  gem 'poltergeist'
  gem 'phantomjs'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'faker'
  gem 'database_cleaner'
  gem 'timecop'
  gem 'parallel_tests'
  gem 'byebug'
  gem 'dotenv-rails'
end

group :test, :darwin do
  gem 'rb-fsevent'
  gem 'capybara-select2', git: 'https://github.com/goodwill/capybara-select2.git'
end

group :test do
  gem 'simplecov'
end

group :doc do
  gem 'sdoc', require: false
end
