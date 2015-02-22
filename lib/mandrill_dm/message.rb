require 'base64'

module MandrillDm
  class Message
    attr_reader :mail

    def initialize(mail)
      @mail = mail
    end

    def auto_text
      nil_true_false?(:auto_text)
    end

    def auto_html
      nil_true_false?(:auto_html)
    end

    def bcc_address
      return_string_value(:bcc_address)
    end

    def from_email
      from.address
    end

    def from_name
      from.display_name
    end

    def headers
      combine_extra_header_fields
    end

    def html
      @mail.html_part ? @mail.html_part.body.decoded : nil
    end

    def important
      @mail[:important].to_s == "true" ? true : false
    end

    def inline_css
      nil_true_false?(:inline_css)
    end

    def preserve_recipients
      nil_true_false?(:preserve_recipients)
    end

    def return_path_domain
      return_string_value(:return_path_domain)
    end

    def signing_domain
      return_string_value(:signing_domain)
    end

    def subaccount
      return_string_value(:subaccount)
    end

    def subject
      @mail.subject
    end

    def tags
      collect_tags
    end

    def text
      @mail.multipart? ? (@mail.text_part ? @mail.text_part.body.decoded : nil) : @mail.body.decoded
    end

    def to
      combine_address_fields.reject{|h| h.nil?}.flatten
    end

    def has_attachment?
      @mail.attachments.any?
    end

    # Returns a Mandrill API compatible attachment hash
    def attachments
      return nil unless @mail.attachments.any?

      @mail.attachments.collect do |attachment|
        { 
          name: attachment.filename,
          type: attachment.mime_type,
          content: Base64.encode64(attachment.body.decoded)
        }
      end
    end

    def to_json
      json_hash = {
        html: html,
        text: text,
        subject: subject,
        from_email: from_email,
        from_name: from_name,
        to: to,
        headers: headers,
        important: important,
        track_opens: track_opens,
        track_clicks: track_clicks,
        auto_text: auto_text,
        auto_html: auto_html,
        inline_css: inline_css,
        url_strip_qs: url_strip_qs,
        preserve_recipients: preserve_recipients,
        view_content_link: view_content_link,
        bcc_address: bcc_address,
        tracking_domain: tracking_domain,
        signing_domain: signing_domain,
        return_path_domain: return_path_domain,
        tags: tags,
        subaccount: subaccount
      }
      has_attachment? ? json_hash.merge(attachments: attachments) : json_hash
    end

    def track_clicks
      nil_true_false?(:track_clicks)
    end

    def track_opens
      nil_true_false?(:track_opens)
    end

    def tracking_domain
      return_string_value(:tracking_domain)
    end

    def url_strip_qs
      nil_true_false?(:url_strip_qs)
    end

    def view_content_link
      nil_true_false?(:view_content_link)
    end

    private

    # Returns an array of tags
    def collect_tags
      @mail[:tags].to_s.split(', ').map { |tag| tag }
    end

    # Returns a single, flattened hash with all to, cc, and bcc addresses
    def combine_address_fields
      %w[to cc bcc].map do |field|
        hash_addresses(@mail[field])
      end
    end

    # Returns a hash of extra headers (not complete)
    def combine_extra_header_fields
      headers = {}
      %w[Reply-To
         X-MC-Track
         X-MC-GoogleAnalytics
         X-MC-GoogleAnalyticsCampaign
         X-MC-URLStripQS
         X-MC-PreserveRecipients
         X-MC-InlineCSS
         X-MC-TrackingDomain
         X-MC-SigningDomain
         X-MC-Subaccount
         X-MC-ViewContentLink
         X-MC-BccAddress
         X-MC-Important
         X-MC-IpPool
         X-MC-ReturnPathDomain].each do |field|
        headers[field] = @mail[field].to_s if @mail[field]
      end
      headers
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

    def return_string_value(field)
      @mail[field] ? @mail[field].to_s : nil
    end

    def nil_true_false?(field)
      @mail[field].nil? ? nil : (@mail[field].to_s == "true" ? true : false)
    end
  end
end
