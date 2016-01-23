require 'base64'

module MandrillDm
  class Message # rubocop:disable ClassLength
    attr_reader :mail

    def initialize(mail)
      @mail = mail
    end

    # Returns a Mandrill API compatible attachment hash
    def attachments
      regular_attachments = mail.attachments.reject(&:inline?)
      regular_attachments.collect do |attachment|
        {
          name: attachment.filename,
          type: attachment.mime_type,
          content: Base64.encode64(attachment.body.decoded)
        }
      end
    end

    # Mandrill uses a different hash for inlined image attachments
    def images
      inline_attachments = mail.attachments.select(&:inline?)
      inline_attachments.collect do |attachment|
        {
          name: attachment.cid,
          type: attachment.mime_type,
          content: Base64.encode64(attachment.body.decoded)
        }
      end
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
      mail.html_part ? mail.html_part.body.decoded : mail.body.decoded
    end

    def important
      mail[:important].to_s == 'true' ? true : false
    end

    def inline_css
      nil_true_false?(:inline_css)
    end

    def merge
      nil_true_false?(:merge)
    end

    def merge_language
      return_string_value(:merge_language)
    end

    # `mail[:merge_vars].value` returns the variables pre-processed,
    # `instance_variable_get('@value')` returns them exactly as they were passed in
    def merge_vars
      mail[:merge_vars] ? mail[:merge_vars].instance_variable_get("@value") : nil
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
      mail.subject
    end

    def tags
      collect_tags
    end

    def text
      return mail.text_part.body.decoded if mail.multipart? && mail.text_part
      nil
    end

    def to
      combine_address_fields.reject(&:nil?).flatten
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

    def to_json # rubocop:disable MethodLength, AbcSize
      json_hash = {
        auto_html: auto_html,
        auto_text: auto_text,
        bcc_address: bcc_address,
        from_email: from_email,
        from_name: from_name,
        headers: headers,
        html: html,
        important: important,
        inline_css: inline_css,
        merge: merge,
        merge_language: merge_language,
        merge_vars: merge_vars,
        preserve_recipients: preserve_recipients,
        return_path_domain: return_path_domain,
        signing_domain: signing_domain,
        subaccount: subaccount,
        subject: subject,
        tags: tags,
        text: text,
        to: to,
        track_clicks: track_clicks,
        track_opens: track_opens,
        tracking_domain: tracking_domain,
        url_strip_qs: url_strip_qs,
        view_content_link: view_content_link
      }

      json_hash[:attachments] = attachments if attachments?
      json_hash[:images] = images if inline_attachments?
      json_hash
    end

  private

    # Returns an array of tags
    def collect_tags
      mail[:tags].to_s.split(', ').map { |tag| tag }
    end

    # Returns a single, flattened hash with all to, cc, and bcc addresses
    def combine_address_fields
      %w(to cc bcc).map do |field|
        hash_addresses(mail[field])
      end
    end

    # Returns a hash of extra headers (not complete)
    def combine_extra_header_fields # rubocop:disable MethodLength
      %w(
        Reply-To
        X-MC-BccAddress
        X-MC-GoogleAnalytics
        X-MC-GoogleAnalyticsCampaign
        X-MC-Important
        X-MC-InlineCSS
        X-MC-IpPool
        X-MC-PreserveRecipients
        X-MC-ReturnPathDomain
        X-MC-SigningDomain
        X-MC-Subaccount
        X-MC-Track
        X-MC-TrackingDomain
        X-MC-URLStripQS
        X-MC-ViewContentLink
      ).each_with_object({}) do |field, headers|
        headers[field] = mail[field].to_s if mail[field]
      end
    end

    # Returns a Mail::Address object using the from field
    def from
      address = mail[:from].formatted
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

    def attachments?
      mail.attachments.any? { |a| !a.inline? }
    end

    def inline_attachments?
      mail.attachments.any?(&:inline?)
    end

    def return_string_value(field)
      mail[field] ? mail[field].to_s : nil
    end

    def nil_true_false?(field)
      return nil if mail[field].nil?
      mail[field].to_s == 'true' ? true : false
    end
  end
end
