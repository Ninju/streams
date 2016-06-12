require 'rubygems'
require 'mocha/setup'

RSpec.configure do |config|
  config.mock_with :mocha
  config.expect_with(:rspec) { |c| c.syntax = :should }
end
