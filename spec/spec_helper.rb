require 'bundler/setup'
require 'rspec/its'
require 'webmock/rspec'
require 'cloud_pay'

Dir["./spec/support/**/*.rb"].each { |f| require f }

WebMock.enable!
WebMock.disable_net_connect!

CloudPay.configure(:test) do |c|
  c.public_key = 'user'
  c.secret_key = 'pass'
  c.host = 'http://localhost:9292'
  c.log = false
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.include CloudPay::RSpec::Helpers

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
