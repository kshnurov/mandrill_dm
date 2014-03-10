require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require "mail"

MandrillDm.configure do |config|
  config.api_key = '1234567890'
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true

  config.before(:all) do 
    Excon.defaults[:mock] = true
    Excon.stub({}, {body: '{}', status: 200}) # stubs any request to return an empty JSON string
  end
end
