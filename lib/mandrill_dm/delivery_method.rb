module MandrillDm
  class DeliveryMethod
    attr_accessor :settings, :response

    def initialize(options = {})
      @settings = options
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def deliver!(mail)
      mandrill_api = Mandrill::API.new(MandrillDm.configuration.api_key)
      message = Message.new(mail)

      if message.template
        @response = mandrill_api.messages.send_template(
          message.template,
          message.template_content,
          message.to_json,
          MandrillDm.configuration.async
        )
      else
        @response = mandrill_api.messages.send(
          message.to_json,
          MandrillDm.configuration.async,
          nil,
          message.send_at
        )
      end
    end
  end
end
