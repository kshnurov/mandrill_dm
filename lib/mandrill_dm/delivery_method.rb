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

      @response = mandrill_deliver(mandrill_api, template, message)
    end

  private

    def mandrill_deliver(mandrill_api, template, message)
      if template.name
        send_template(mandrill_api, template, message)
      else
        send(mandrill_api, message)
      end
    end

    def send(mandrill_api, message)
      mandrill_api.messages.send(
        message.to_json,
        MandrillDm.configuration.async
      )
    end

    def send_template(mandrill_api, template, message)
      mandrill_api.messages.send_template(
        template.name,
        template.content,
        message.to_json,
        MandrillDm.configuration.async
      )
    end
  end
end
