module MandrillDm
  class DeliveryMethod
    attr_accessor :settings, :response

    def initialize(options = {})
      @settings = options
    end

    def deliver!(mail)
      mandrill_api = Mandrill::API.new(MandrillDm.configuration.api_key)
      message = Message.new(mail)
      @response = mandrill_api.messages.send(
        message.to_json,
        MandrillDm.configuration.async
      )
    end
  end
end
