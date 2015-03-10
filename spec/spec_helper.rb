require 'simplecov'
SimpleCov.start do
  coverage_dir 'tmp/coverage'
  add_filter '/spec/'

  SimpleCov.at_exit do
    SimpleCov.result.format!
    system('open tmp/coverage/index.html') if RUBY_PLATFORM['darwin']
  end
end if ENV['COVERAGE']

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'mail'

MandrillDm.configure do |config|
  config.api_key = '1234567890'
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true

  config.before(:all) do
    Excon.defaults[:mock] = true
    # stubs any request to return an empty JSON string
    Excon.stub({}, body: '{}', status: 200)
  end
end
