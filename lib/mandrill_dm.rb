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
    logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    logger.error '!!! MIGRATE from Mandrill IMMEDIATELY: https://github.com/kshnurov/mandrill_dm/MIGRATE'
    Warning.warn "!!! MIGRATE from Mandrill IMMEDIATELY: https://github.com/kshnurov/mandrill_dm/MIGRATE\n"

    self.configuration ||= Configuration.new
    yield(configuration)
  end

  # @see MandrillDm.configure
  class Configuration
    attr_accessor :api_key, :async, :ip_pool

    def initialize
      @api_key = ''
      @async = false
      @ip_pool = nil
    end
  end
end
