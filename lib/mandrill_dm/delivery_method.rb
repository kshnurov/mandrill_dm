module MandrillDm
  class DeliveryMethod
    attr_accessor :settings, :response

    def initialize(options = {})
      @settings = {
        api_key: MandrillDm.configuration.api_key
      }.merge!(options)
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def deliver!(mail)
      logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
      logger.error '!!! MIGRATE from Mandrill IMMEDIATELY: https://github.com/kshnurov/mandrill_dm/blob/master/MIGRATE'

      mandrill_api = Mandrill::API.new(settings[:api_key])
      message = Message.new(mail)
      @response = if message.template
                    mandrill_api.messages.send_template(
                      message.template,
                      message.template_content,
                      message.to_json,
                      MandrillDm.configuration.async,
                      message.ip_pool || MandrillDm.configuration.ip_pool,
                      message.send_at
                    )
                  else
                    mandrill_api.messages.send(
                      message.to_json,
                      MandrillDm.configuration.async,
                      message.ip_pool || MandrillDm.configuration.ip_pool,
                      message.send_at
                    )
                  end
    end
  end
end
