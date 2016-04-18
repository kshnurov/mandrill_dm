require 'mandrill'
require 'date'
require_relative 'mandrill_dm/message'
require_relative 'mandrill_dm/delivery_method'
require_relative 'mandrill_dm/railtie' if defined? Rails

module MandrillDm
  class << self
    attr_accessor :configuration
  end

  # Call this method to modify defaults in your initializers.
  #
  # @example
  #   MandrillDm.configure do |config|
  #     config.api_key = '1234567890'
  #   end
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  # @see MandrillDm.configure
  class Configuration
    attr_accessor :api_key, :async

    def initialize
      @api_key = ''
      @async = false
    end
  end
end
