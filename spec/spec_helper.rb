ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
# require 'rspec/autorun'
require 'capybara/rspec'
require "paperclip/matchers"
require 'database_cleaner'
require 'monetize/core_extensions'
require "money-rails/test_helpers"
require 'capybara/poltergeist'
require 'simplecov'
require 'public_activity/testing'

def zeus_running?
  File.exists? '.zeus.sock'
end

Dir[Rails.root.join("app/datatables/*datatable.rb")].each { |f| require_relative f }
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

Capybara.default_wait_time = 10
Capybara.javascript_driver = :poltergeist #:webkit

PublicActivity.enabled = false

Devise.setup do |config|
  config.stretches = 1
end

SimpleCov.start

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, :type => :controller
  config.include Paperclip::Shoulda::Matchers
  config.include MoneyRails::TestHelpers
  config.include Warden::Test::Helpers

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  config.before(:suite) do
    Warden.test_mode!
  end

  config.before(:all) do
    DeferredGarbageCollection.start
  end

  config.after(:all) do
    DeferredGarbageCollection.reconsider
  end

  config.before :each do
    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction
    else
      DatabaseCleaner.strategy = :truncation
    end
    DatabaseCleaner.start
  end

  config.after(:each) do
    Capybara.reset_sessions! if defined?(page) # page is not defined on non-JS tests
    DatabaseCleaner.clean
    Warden.test_reset!
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
