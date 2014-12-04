require 'simplecov'
SimpleCov.start

require 'rspec'
require 'webmock/rspec'

require_relative '../lib/jenkins_config_finder'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end