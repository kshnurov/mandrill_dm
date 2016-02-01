module MandrillDm
  class Template
    attr_reader :mail

    def initialize(mail)
      @mail = mail
    end

    # ActionMailer is using the 'template_name', so we can't use it.
    def name
      mail[:template] ? mail[:template].to_s : nil
    end

    def content
      return [] unless mail[:template_content]
      mail[:template_content].instance_variable_get('@value')
    end
  end
end
