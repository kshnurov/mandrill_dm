module MandrillDm
  class DeliveryMethod
    attr_accessor :settings

    def initialize(options = {})
      self.settings = options
    end

    def deliver!(mail)
      mandrill = Mandrill::API.new(MandrillDm.configuration.api_key)
      message = Message.new(mail).to_json
      result = mandrill.messages.send(message)
      mail.store_mandrill_response(result)
    end
  end
end
