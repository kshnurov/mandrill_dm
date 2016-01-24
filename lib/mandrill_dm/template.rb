module MandrillDm
  class Template
    attr_reader :mail

    def initialize(mail)
      @mail = mail
    end

    def name
      mail[:template_name] ? mail[:template_name].to_s : nil
    end

    def content
      return [] unless mail[:template_content]
      mail[:template_content].instance_variable_get('@value')
    end
  end
end
