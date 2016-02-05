module MandrillDm
  class DeliveryMethod
    @deliveries = []
    class << self; attr_reader :deliveries; end

    attr_accessor :settings, :response

    def initialize(options = {})
      @settings = options
    end

    def deliver!(mail)
      mandrill_api = Mandrill::API.new(MandrillDm.configuration.api_key)
      message = Message.new(mail)
      self.class.deliveries << mail
      @response = mandrill_api.messages.send(
        message.to_json,
        MandrillDm.configuration.async
      )
    end
  end
end
