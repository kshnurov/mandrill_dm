module MandrillDm
  class DeliveryMethod
    attr_accessor :settings, :response

    def initialize(options = {})
      @settings = options
    end

    def deliver!(mail)
      mandrill_api = Mandrill::API.new(MandrillDm.configuration.api_key)

      template = Template.new(mail)
      message = Message.new(mail)

      @response = if template.name
                    mandrill_api.messages.send_template(
                      template.name,
                      template.content,
                      message.to_json,
                      MandrillDm.configuration.async
                    )
                  else
                    mandrill_api.messages.send(
                      message.to_json,
                      MandrillDm.configuration.async
                    )
                  end
    end
  end
end
