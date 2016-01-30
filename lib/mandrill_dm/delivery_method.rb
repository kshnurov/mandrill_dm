module MandrillDm
  class DeliveryMethod
    attr_accessor :settings, :response

    def initialize(options = {})
      @settings = options
    end

    def deliver!(mail)
      @message = Message.new(mail)
      @response = if @message.template
                    send_template
                  else
                    send_message
                  end
    end

  private

    def send_template
      mandrill_api.messages.send_template(
        @message.template,
        @message.template_content,
        @message.to_json,
        MandrillDm.configuration.async
      )
    end

    def send_message
      mandrill_api.messages.send(
        @message.to_json,
        MandrillDm.configuration.async
      )
    end

    def mandrill_api
      @mandrill_api ||= Mandrill::API.new(MandrillDm.configuration.api_key)
    end
  end
end
