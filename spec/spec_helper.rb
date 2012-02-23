require 'bundler/setup'

require 'simplecov'
SimpleCov.start

require 'rspec'
Dir[File.expand_path('../support/**/*', __FILE__)].each { |f| require f }

RSpec.configure do |config|
end
