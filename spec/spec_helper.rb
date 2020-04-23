# frozen_string_literal: true

# require "simplecov"
# SimpleCov.start

require "dotenv/load"
require "mavenlink"
require "rspec"
require "webmock/rspec"
require "vcr"

require_relative "../lib/mavenlink"

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data("<API_TOKEN>") { ENV["MAVENLINK_API_KEY"] }
end

RSpec.configure do |config|
  config.before(:suite) do
    Mavenlink.api_key = ENV["MAVENLINK_API_KEY"]
  end
end
