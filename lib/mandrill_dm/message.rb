module MandrillDm
  class Message
    attr_reader :mail

    def initialize(mail)
      @mail = mail
    end

    def from_email
      from.address
    end

    def from_name
      from.display_name
    end

    def html
      @mail.html_part ? @mail.html_part.body.decoded : @mail.body.decoded
    end

    def subject
      @mail.subject
    end

    def text
      @mail.multipart? ? (@mail.text_part ? @mail.text_part.body.decoded : nil) : nil
    end

    def to
      combine_address_fields.reject{|h| h.nil?}.flatten
    end

    def to_json
      {
        html: html,
        text: text,
        subject: subject,
        from_email: from_email,
        from_name: from_name,
        to: to
      }
    end

    private

    # Returns a single, flattened hash with all to, cc, and bcc addresses
    def combine_address_fields
      %w[to cc bcc].map do |field|
        hash_addresses(@mail[field])
      end
    end

    # Returns a Mail::Address object using the from field
    def from
      address = @mail[:from].formatted
      Mail::Address.new(address.first)
    end

    # Returns a Mandrill API compatible email address hash
    def hash_addresses(address_field)
      return nil unless address_field

      address_field.formatted.map do |address|
        address_obj = Mail::Address.new(address)
        {
          email: address_obj.address,
          name: address_obj.display_name,
          type: address_field.name.downcase
        }
      end
    end
  end
end
