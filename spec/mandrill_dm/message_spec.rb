require 'spec_helper'
require 'time'

describe MandrillDm::Message do
  def new_mail(options = {}, &blk)
    Mail.new(options, &blk)
  end

  describe '#attachments' do
    it 'takes an attachment' do
      mail = new_mail(to: 'name@domain.tld', content_type: 'multipart/alternative')
      mail.attachments['text.txt'] = {
        mime_type: 'text/plain',
        content: 'This is a test'
      }

      message = described_class.new(mail)
      expect(message.attachments).to eq(
        [{ name: 'text.txt', type: 'text/plain', content: "VGhpcyBpcyBhIHRlc3Q=\n" }]
      )
    end

    it 'ignores inline attachments' do
      mail = new_mail(to: 'name@domain.tld', content_type: 'multipart/alternative')
      mail.attachments.inline['text.txt'] = {
        mime_type: 'text/plain',
        content: 'This is a test'
      }

      message = described_class.new(mail)
      expect(message.attachments).to eq([])
    end
  end

  describe '#auto_html' do
    it 'takes a auto_html with true' do
      mail = new_mail(auto_html: true)
      message = described_class.new(mail)
      expect(message.auto_html).to be true
    end

    it 'takes a auto_html with false' do
      mail = new_mail(auto_html: false)
      message = described_class.new(mail)
      expect(message.auto_html).to be false
    end

    it 'does not take an auto_html value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.auto_html).to be_nil
    end
  end

  describe '#auto_text' do
    it 'takes a auto_text with true' do
      mail = new_mail(auto_text: true)
      message = described_class.new(mail)
      expect(message.auto_text).to be true
    end

    it 'takes a auto_text with false' do
      mail = new_mail(auto_text: false)
      message = described_class.new(mail)
      expect(message.auto_text).to be false
    end

    it 'does not take an auto_text value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.auto_text).to be_nil
    end
  end

  describe '#bcc_address' do
    it 'takes a bcc_address' do
      mail = new_mail(bcc_address: 'bart@simpsons.com')
      message = described_class.new(mail)
      expect(message.bcc_address).to eq('bart@simpsons.com')
    end

    it 'does not take bcc_address value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.bcc_address).to be_nil
    end
  end

  describe '#from_email' do
    it 'takes a single email' do
      mail = new_mail(from: 'from_name@domain.tld')
      message = described_class.new(mail)
      expect(message.from_email).to eq('from_name@domain.tld')
    end

    it 'takes a single email with a display name' do
      mail = new_mail(from: 'John Doe <from_name@domain.tld>')
      message = described_class.new(mail)
      expect(message.from_email).to eq('from_name@domain.tld')
    end
  end

  describe '#from_name' do
    it 'takes a single email' do
      mail = new_mail(from: 'from_name@domain.tld')
      message = described_class.new(mail)
      expect(message.from_name).to eq(nil)
    end

    it 'takes a single email with a display name' do
      mail = new_mail(from: 'John Doe <from_name@domain.tld>')
      message = described_class.new(mail)
      expect(message.from_name).to eq('John Doe')
    end
  end

  describe '#global_merge_vars' do
    it 'takes an array of global_merge_vars' do
      global_merge_vars = [{ 'name' => 'TESTVAR', 'content' => 'testcontent' }]
      mail = new_mail(global_merge_vars: global_merge_vars)
      message = described_class.new(mail)
      expect(message.global_merge_vars).to eq(global_merge_vars)
    end

    it 'takes an array of multiple global_merge_vars' do
      global_merge_vars = [
        { 'name' => 'TESTVAR', 'content' => 'testcontent' },
        { 'name' => 'TESTVAR2', 'content' => 'testcontent2' }
      ]
      mail = new_mail(global_merge_vars: global_merge_vars)
      message = described_class.new(mail)
      expect(message.global_merge_vars).to eq(global_merge_vars)
    end

    it 'does not use gsub to convert string into JSON' do
      global_merge_vars = [
        { 'name' => 'TESTVAR', 'content' => 'do you know how :async works?' },
        { 'name' => 'TESTVAR2', 'content' => 'more than 10 recipients => always "true"!' }
      ]
      mail = new_mail(global_merge_vars: global_merge_vars)
      message = described_class.new(mail)
      expect(message.global_merge_vars).to eq(global_merge_vars)
    end

    it 'does not take global_merge_vars value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.global_merge_vars).to be_nil
    end
  end

  pending '#google_analytics_domains'
  pending '#google_analytics_campaign'

  describe '#headers' do
    def check_header(header)
      mail = new_mail(headers: header)
      message = described_class.new(mail)
      expect(message.headers).to eq(header)
    end

    it 'adds `Reply-To` header' do
      check_header 'Reply-To' => 'name1@domain.tld'
    end

    it 'adds `X-MC-BccAddress` header' do
      check_header 'X-MC-BccAddress' => 'name1@domain.tld'
    end

    it 'adds `X-MC-GoogleAnalytics` header' do
      check_header 'X-MC-GoogleAnalytics' => 'foo.com, bar.com'
    end

    it 'adds `X-MC-GoogleAnalyticsCampaign` header' do
      check_header 'X-MC-GoogleAnalyticsCampaign' => 'foo@bar.com'
    end

    it 'adds `X-MC-Track` header' do
      check_header 'X-MC-Track' => 'opens, clicks_htmlonly'
    end

    it 'adds `X-MC-URLStripQS` header' do
      check_header 'X-MC-URLStripQS' => 'true'
    end
  end

  describe '#html' do
    it 'takes a non-multipart message' do
      mail = new_mail(
        to: 'name@domain.tld',
        body: '<html><body>Hello world!</body></html>'
      )

      message = described_class.new(mail)
      expect(message.html).to eq('<html><body>Hello world!</body></html>')
    end

    it 'takes a multipart message' do
      html_part = Mail::Part.new do
        content_type 'text/html'
        body '<html><body>Hello world!</body></html>'
      end

      text_part = Mail::Part.new do
        content_type 'text/plain'
        body 'Hello world!'
      end

      mail = new_mail(to: 'name@domain.tld', content_type: 'multipart/alternative') do |p|
        p.html_part = html_part
        p.text_part = text_part
      end
      message = described_class.new(mail)
      expect(message.html).to eq('<html><body>Hello world!</body></html>')
    end
  end

  describe '#images' do
    it 'takes an inline attachment' do
      mail = new_mail(to: 'name@domain.tld', content_type: 'multipart/alternative')
      mail.attachments.inline['text.jpg'] = {
        mime_type: 'image/jpg',
        content: 'This is a test'
      }

      message = described_class.new(mail)
      expect(message.images).to eq(
        [{ name: mail.attachments[0].cid,
           type: 'image/jpg',
           content: "VGhpcyBpcyBhIHRlc3Q=\n" }]
      )
    end

    it 'ignores normal attachments' do
      mail = new_mail(to: 'name@domain.tld', content_type: 'multipart/alternative')
      mail.attachments['text.txt'] = {
        mime_type: 'text/plain',
        content: 'This is a test'
      }

      message = described_class.new(mail)
      expect(message.images).to eq([])
    end
  end

  describe '#important' do
    it 'takes an important email' do
      mail = new_mail(important: true)
      message = described_class.new(mail)
      expect(message.important).to be true
    end

    it 'takes a non-important email' do
      mail = new_mail(important: false)
      message = described_class.new(mail)
      expect(message.important).to be false
    end

    it 'takes a default important value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.important).to be false
    end
  end

  describe '#inline_css' do
    it 'takes a inline_css with true' do
      mail = new_mail(inline_css: true)
      message = described_class.new(mail)
      expect(message.inline_css).to be true
    end

    it 'takes a inline_css with false' do
      mail = new_mail(inline_css: false)
      message = described_class.new(mail)
      expect(message.inline_css).to be false
    end

    it 'does not take an inline_css value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.inline_css).to be_nil
    end
  end

  describe '#merge' do
    it 'takes a merge with true' do
      mail = new_mail(merge: true)
      message = described_class.new(mail)
      expect(message.merge).to be true
    end

    it 'takes a merge with false' do
      mail = new_mail(merge: false)
      message = described_class.new(mail)
      expect(message.merge).to be false
    end

    it 'does not take a merge value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.merge).to be_nil
    end
  end

  describe '#merge_language' do
    it 'takes a merge_language' do
      mail = new_mail(merge_language: 'handlebars')
      message = described_class.new(mail)
      expect(message.merge_language).to eq('handlebars')
    end

    it 'does not take merge_language value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.merge_language).to be_nil
    end
  end

  describe '#merge_vars' do
    it 'takes an array of merge_vars definitions' do
      vars = [
        { 'name' => 'MY_VAR_1', 'content' => 'foo' },
        { 'name' => 'MY_VAR_2', 'content' => 'bar' }
      ]
      merge_vars = [{ 'rcpt' => 'a@a.de', 'vars' => vars }]
      mail = new_mail(merge_vars: merge_vars)
      message = described_class.new(mail)
      expect(message.merge_vars).to eq(merge_vars)
    end

    it 'takes an array of multiple merge_vars' do
      vars = [
        { 'name' => 'MY_VAR_1', 'content' => 'foo' },
        { 'name' => 'MY_VAR_2', 'content' => 'bar' }
      ]
      merge_vars = [
        { 'rcpt' => 'name1@domain.tld', 'vars' => vars },
        { 'rcpt' => 'name2@domain.tld', 'vars' => vars }
      ]
      mail = new_mail(merge_vars: merge_vars)
      message = described_class.new(mail)
      expect(message.merge_vars).to eq(merge_vars)
    end

    it 'does not use gsub to convert string into JSON' do
      vars = [
        { 'name' => 'MY_VAR_1', 'content' => 'do you know how :async works?' },
        { 'name' => 'MY_VAR_2', 'content' => 'more than 10 recipients => always true!' }
      ]
      merge_vars = [{ 'rcpt' => 'a@a.de', 'vars' => vars }]
      mail = new_mail(merge_vars: merge_vars)
      message = described_class.new(mail)
      expect(message.merge_vars).to eq(merge_vars)
    end

    it 'does not take merge_vars value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.merge_vars).to be_nil
    end
  end

  describe '#metadata' do
    it 'takes a metadata with a hash' do
      mail = new_mail(metadata: {:mail_internal_id => 'nice-uuid-field'})
      message = described_class.new(mail)
      expect(message.metadata).to eq({"mail_internal_id" => 'nice-uuid-field'})
    end

    it 'does not take metadata value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.metadata).to be_nil
    end

  end

  describe '#preserve_recipients' do
    it 'takes a preserve_recipients with true' do
      mail = new_mail(preserve_recipients: true)
      message = described_class.new(mail)
      expect(message.preserve_recipients).to be true
    end

    it 'takes a preserve_recipients with false' do
      mail = new_mail(preserve_recipients: false)
      message = described_class.new(mail)
      expect(message.preserve_recipients).to be false
    end

    it 'does not take preserve_recipients value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.preserve_recipients).to be_nil
    end
  end

  pending '#recipient_metadata'

  describe '#return_path_domain' do
    it 'takes a return_path_domain' do
      mail = new_mail(return_path_domain: 'return_path_domain.com')
      message = described_class.new(mail)
      expect(message.return_path_domain).to eq('return_path_domain.com')
    end

    it 'does not take return_path_domain value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.return_path_domain).to be_nil
    end
  end

  describe '#send_at' do
    it 'takes a send_at DateTime and converts to format expected by Mandrill' do
      # from API docs: this message should be sent as a UTC timestamp in YYYY-MM-DD HH:MM:SS format
      mail = new_mail(send_at: Time.new(2016,8,8, 13, 36, 25, "-05:00"))
      message = described_class.new(mail)
      expect(message.send_at).to eq("2016-08-08 18:36:25")
    end

    it 'does not take signing_domain value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.send_at).to be_nil
    end

  end

  describe '#signing_domain' do
    it 'takes a signing_domain' do
      mail = new_mail(signing_domain: 'signing_domain.com')
      message = described_class.new(mail)
      expect(message.signing_domain).to eq('signing_domain.com')
    end

    it 'does not take signing_domain value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.signing_domain).to be_nil
    end
  end

  describe '#subaccount' do
    it 'takes a subaccount' do
      mail = new_mail(subaccount: 'abc123')
      message = described_class.new(mail)
      expect(message.subaccount).to eq('abc123')
    end

    it 'does not take subaccount value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.subaccount).to be_nil
    end
  end

  describe '#subject' do
    it 'takes a subject' do
      mail = new_mail(subject: 'Test Subject')
      message = described_class.new(mail)
      expect(message.subject).to eq('Test Subject')
    end
  end

  describe '#tags' do
    it 'takes a tag' do
      mail = new_mail(tags: 'test_tag')
      message = described_class.new(mail)
      expect(message.tags).to eq(['test_tag'])
    end

    it 'takes an array of tags' do
      mail = new_mail(tags: %w(test_tag1 test_tag2))
      message = described_class.new(mail)
      expect(message.tags).to eq(%w(test_tag1 test_tag2))
    end
  end

  describe '#text' do
    it 'does not take a non-multipart message' do
      mail = new_mail(to: 'name@domain.tld', body: 'Hello world!')
      message = described_class.new(mail)
      expect(message.text).to eq(nil)
    end

    it 'takes a multipart message' do
      html_part = Mail::Part.new do
        content_type 'text/html'
        body '<html><body>Hello world!</body></html>'
      end

      text_part = Mail::Part.new do
        content_type 'text/plain'
        body 'Hello world!'
      end

      mail = new_mail(to: 'name@domain.tld', content_type: 'multipart/alternative') do |p|
        p.html_part = html_part
        p.text_part = text_part
      end
      message = described_class.new(mail)
      expect(message.text).to eq('Hello world!')
    end
  end

  describe '#to' do
    it 'takes a single email' do
      mail = new_mail(to: 'name@domain.tld')
      message = described_class.new(mail)
      expect(message.to).to eq([{ email: 'name@domain.tld', name: nil, type: 'to' }])
    end

    it 'takes a single email with a display name' do
      mail = new_mail(to: 'John Doe <name@domain.tld>')
      message = described_class.new(mail)
      expect(message.to).to eq(
        [{ email: 'name@domain.tld', name: 'John Doe', type: 'to' }]
      )
    end

    it 'takes an array of emails' do
      mail = new_mail(to: ['name1@domain.tld', 'name2@domain.tld'])
      message = described_class.new(mail)
      expect(message.to).to eq(
        [
          { email: 'name1@domain.tld', name: nil, type: 'to' },
          { email: 'name2@domain.tld', name: nil, type: 'to' }
        ]
      )
    end

    it 'takes an array of emails with a display names' do
      mail = new_mail(
        to: ['John Doe <name1@domain.tld>', 'Jane Smith <name2@domain.tld>']
      )

      message = described_class.new(mail)
      expect(message.to).to eq(
        [
          { email: 'name1@domain.tld', name: 'John Doe', type: 'to' },
          { email: 'name2@domain.tld', name: 'Jane Smith', type: 'to' }
        ]
      )
    end

    it 'combines to, cc, and bcc fields' do
      mail = new_mail(
        to: 'John Doe <name1@domain.tld>',
        cc: 'Jane Smith <name2@domain.tld>',
        bcc: 'Jenny Craig <name3@domain.tld>'
      )

      message = described_class.new(mail)
      expect(message.to).to eq(
        [
          { email: 'name1@domain.tld', name: 'John Doe', type: 'to' },
          { email: 'name2@domain.tld', name: 'Jane Smith', type: 'cc' },
          { email: 'name3@domain.tld', name: 'Jenny Craig', type: 'bcc' }
        ]
      )
    end
  end

  describe '#track_clicks' do
    it 'takes a track_clicks with true' do
      mail = new_mail(track_clicks: true)
      message = described_class.new(mail)
      expect(message.track_clicks).to be true
    end

    it 'takes a track_clicks with false' do
      mail = new_mail(track_clicks: false)
      message = described_class.new(mail)
      expect(message.track_clicks).to be false
    end

    it 'does not take a track_clicks value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.track_clicks).to be_nil
    end
  end

  describe '#track_opens' do
    it 'takes a track_opens with true' do
      mail = new_mail(track_opens: true)
      message = described_class.new(mail)
      expect(message.track_opens).to be true
    end

    it 'takes a track_opens with false' do
      mail = new_mail(track_opens: false)
      message = described_class.new(mail)
      expect(message.track_opens).to be false
    end

    it 'does not take a track_opens value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.track_opens).to be_nil
    end
  end

  describe '#tracking_domain' do
    it 'takes a tracking_domain' do
      mail = new_mail(tracking_domain: 'tracking_domain.com')
      message = described_class.new(mail)
      expect(message.tracking_domain).to eq('tracking_domain.com')
    end

    it 'does not take tracking_domain value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.tracking_domain).to be_nil
    end
  end

  describe '#url_strip_qs'do
    it 'takes a url_strip_qs with true' do
      mail = new_mail(url_strip_qs: true)
      message = described_class.new(mail)
      expect(message.url_strip_qs).to be true
    end

    it 'takes a url_strip_qs with false' do
      mail = new_mail(url_strip_qs: false)
      message = described_class.new(mail)
      expect(message.url_strip_qs).to be false
    end

    it 'does not take an url_strip_qs value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.url_strip_qs).to be_nil
    end
  end

  describe '#view_content_link' do
    it 'takes a view_content_link with true' do
      mail = new_mail(view_content_link: true)
      message = described_class.new(mail)
      expect(message.view_content_link).to be true
    end

    it 'takes a view_content_link with false' do
      mail = new_mail(view_content_link: false)
      message = described_class.new(mail)
      expect(message.view_content_link).to be false
    end

    it 'does not take view_content_link value' do
      mail = new_mail
      message = described_class.new(mail)
      expect(message.view_content_link).to be_nil
    end
  end

  describe '#to_json' do
    it 'returns a proper JSON response for the Mandrill API' do
      mail = new_mail(body: 'test',
                      from: 'name@domain.tld',
                      headers: { 'Reply-To' => 'name1@domain.tld' },
                      tags: 'test_tag')
      message = described_class.new(mail)
      expect(message.to_json).to(
        include(:from_email, :from_name, :html, :subject, :to, :headers, :tags)
      )
    end

    it 'returns a proper JSON response for the Mandrill API with attachments' do
      mail = new_mail(body: 'test', from: 'name@domain.tld')
      mail.attachments['text.txt'] = {
        mime_type: 'text/plain',
        content: 'This is a test'
      }

      message = described_class.new(mail)
      expect(message.to_json).to(
        include(:from_email, :from_name, :html, :subject, :to, :attachments)
      )
    end

    it 'returns a proper JSON response for the Mandrill API with metadata' do
      mail = new_mail(body: 'test', from: 'name@domain.tld', metadata: {foo: "bar"})

      message = described_class.new(mail)
      expect(message.to_json).to(
        include(:from_email, :from_name, :html, :subject, :to, :metadata)
      )
    end
  end
end
