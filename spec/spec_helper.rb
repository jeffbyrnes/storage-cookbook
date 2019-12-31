require 'chefspec'
require 'chefspec/berkshelf'
require_relative '../libraries/storage'

RSpec.configure do |config|
  config.add_formatter 'documentation'

  # Add JUnit output for CI
  if ENV['CI']
    config.add_formatter 'RspecJunitFormatter', './test-results/verify/results.xml'
  end
end
