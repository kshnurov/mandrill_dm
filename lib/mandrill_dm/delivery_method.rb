module MandrillDm
  class DeliveryMethod
    attr_accessor :settings, :response

    def initialize(options = {})
      @settings = options
    end

    def deliver!(mail)
      mandrill_api = Mandrill::API.new(MandrillDm.configuration.api_key)
      @message = Message.new(mail)
      if @message.template
        @response = mandrill_api.messages.send_template(@message.template, template_content, message_json)
      else
        @response = mandrill_api.messages.send(message_json)
      end
    end

    private

      def message_json
        @message_json ||= @message.to_json
      end

      def template_content
        template_cnt = []
        template_cnt_hash = eval(@message.template_content)
        template_cnt_hash.each do |name, content|
          template_cnt.push({
            name: name.to_s,
            content: content.is_a?(Symbol) ? message_json[content] : content
          })
        end
        template_cnt
      end
  end
end
