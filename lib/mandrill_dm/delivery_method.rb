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
        template_content,
        message_json,
        MandrillDm.configuration.async
      )
    end

    def send_message
      mandrill_api.messages.send(
        message_json,
        MandrillDm.configuration.async
      )
    end

    def mandrill_api
      @mandrill_api ||= Mandrill::API.new(MandrillDm.configuration.api_key)
    end

    def message_json
      @message_json ||= @message.to_json
    end

    def template_content
      return [{ name: 'blank', content: '' }] unless @message.template_content
      template_cnt = []
      @message.template_content.each do |hash|
        content = hash[:content]
        template_cnt.push(
          name: hash[:name].to_s,
          content: content.is_a?(Symbol) ? message_json[content] : content
        )
      end
      template_cnt
    end
  end
end
