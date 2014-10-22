require 'spec_helper'

describe MandrillDm::Message do
  def mail(options={}, &blk)
    Mail.new(options, &blk)
  end

  describe '#from_email' do
    it 'takes a single email' do
      mail = mail(from: 'from_name@domain.tld')
      message = described_class.new(mail)
      expect(message.from_email).to eq('from_name@domain.tld')
    end

    it 'takes a single email with a display name' do
      mail = mail(from: 'John Doe <from_name@domain.tld>')
      message = described_class.new(mail)
      expect(message.from_email).to eq('from_name@domain.tld')
    end
  end

  describe '#from_name' do
    it 'takes a single email' do
      mail = mail(from: 'from_name@domain.tld')
      message = described_class.new(mail)
      expect(message.from_name).to eq(nil)
    end

    it 'takes a single email with a display name' do
      mail = mail(from: 'John Doe <from_name@domain.tld>')
      message = described_class.new(mail)
      expect(message.from_name).to eq('John Doe')
    end
  end

  describe '#html' do
    it 'takes a non-multipart message' do
      mail = mail(to: 'name@domain.tld', body: '<html><body>Hello world!</body></html>')
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

      mail = mail(to: 'name@domain.tld', content_type: 'multipart/alternative') do |p|
        p.html_part = html_part
        p.text_part = text_part
      end
      message = described_class.new(mail)
      expect(message.html).to eq('<html><body>Hello world!</body></html>')
    end
  end

  describe '#text' do
    it 'does not take a non-multipart message' do
      mail = mail(to: 'name@domain.tld', body: 'Hello world!')
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

      mail = mail(to: 'name@domain.tld', content_type: 'multipart/alternative') do |p|
        p.html_part = html_part
        p.text_part = text_part
      end
      message = described_class.new(mail)
      expect(message.text).to eq('Hello world!')
    end
  end

  describe '#to' do
    it 'takes a single email' do
      mail = mail(to: 'name@domain.tld')
      message = described_class.new(mail)
      expect(message.to).to eq([{email: 'name@domain.tld', name: nil, type: 'to'}])
    end

    it 'takes a single email with a display name' do
      mail = mail(to: 'John Doe <name@domain.tld>')
      message = described_class.new(mail)
      expect(message.to).to eq([{email: 'name@domain.tld', name: 'John Doe', type: 'to'}])
    end

    it 'takes an array of emails' do
      mail = mail(to: ['name1@domain.tld', 'name2@domain.tld'])
      message = described_class.new(mail)
      expect(message.to).to eq(
        [
          {email: 'name1@domain.tld', name: nil, type: 'to'},
          {email: 'name2@domain.tld', name: nil, type: 'to'}
        ]
      )
    end

    it 'takes an array of emails with a display names' do
      mail = mail(to: ['John Doe <name1@domain.tld>', 'Jane Smith <name2@domain.tld>'])
      message = described_class.new(mail)
      expect(message.to).to eq(
        [
          {email: 'name1@domain.tld', name: 'John Doe', type: 'to'},
          {email: 'name2@domain.tld', name: 'Jane Smith', type: 'to'}
        ]
      )
    end

    it 'combines to, cc, and bcc fields' do
      mail = mail(to: 'John Doe <name1@domain.tld>', cc: 'Jane Smith <name2@domain.tld>', bcc: 'Jenny Craig <name3@domain.tld>')
      message = described_class.new(mail)
      expect(message.to).to eq(
        [
          {email: 'name1@domain.tld', name: 'John Doe', type: 'to'},
          {email: 'name2@domain.tld', name: 'Jane Smith', type: 'cc'},
          {email: 'name3@domain.tld', name: 'Jenny Craig', type: 'bcc'}
        ]
      )
    end
  end

  describe '#subject' do
    it 'takes a subject' do
      mail = mail(subject: 'Test Subject')
      message = described_class.new(mail)
      expect(message.subject).to eq('Test Subject')
    end
  end

  describe '#headers' do
    it 'takes an extra header' do
      mail = mail(headers: {'Reply-To' => 'name1@domain.tld'})
      message = described_class.new(mail)
      expect(message.headers).to eq({'Reply-To' => 'name1@domain.tld'})
    end

    it 'takes an extra header with reply_to' do
      mail = mail(reply_to: 'name1@domain.tld')
      message = described_class.new(mail)
      expect(message.headers).to eq({'Reply-To' => 'name1@domain.tld'})
    end

    it 'takes more extra headers' do
      mail = mail(headers: {'Reply-To' => 'name1@domain.tld', 'X-MC-Track' => 'opens, clicks_htmlonly', 'X-MC-URLStripQS' => 'true'})
      message = described_class.new(mail)
      expect(message.headers).to eq(
        {
          'Reply-To' => 'name1@domain.tld',
          'X-MC-Track' => 'opens, clicks_htmlonly',
          'X-MC-URLStripQS' => 'true'
        }
      )
    end
  end

  describe '#important' do
    it 'takes an important email' do
      mail = mail(important: true)
      message = described_class.new(mail)
      expect(message.important).to be true
    end

    it 'takes a non important email' do
      mail = mail(important: false)
      message = described_class.new(mail)
      expect(message.important).to be false
    end

    it 'takes a default important value' do
      mail = mail()
      message = described_class.new(mail)
      expect(message.important).to be false
    end
  end

  describe '#track_opens' do
    it 'takes a track_opens with true' do
      mail = mail(track_opens: true)
      message = described_class.new(mail)
      expect(message.track_opens).to be true
    end

    it 'takes a track_opens with false' do
      mail = mail(track_opens: false)
      message = described_class.new(mail)
      expect(message.track_opens).to be false
    end

    it 'does not take a track_opens value' do
      mail = mail()
      message = described_class.new(mail)
      expect(message.track_opens).to be_nil
    end
  end

  describe '#track_clicks' do
    it 'takes a track_clicks with true' do
      mail = mail(track_clicks: true)
      message = described_class.new(mail)
      expect(message.track_clicks).to be true
    end

    it 'takes a track_clicks with false' do
      mail = mail(track_clicks: false)
      message = described_class.new(mail)
      expect(message.track_clicks).to be false
    end

    it 'does not take a track_clicks value' do
      mail = mail()
      message = described_class.new(mail)
      expect(message.track_clicks).to be_nil
    end
  end

  describe '#auto_text' do
    it 'takes a auto_text with true' do
      mail = mail(auto_text: true)
      message = described_class.new(mail)
      expect(message.auto_text).to be true
    end

    it 'takes a auto_text with false' do
      mail = mail(auto_text: false)
      message = described_class.new(mail)
      expect(message.auto_text).to be false
    end

    it 'does not take an auto_text value' do
      mail = mail()
      message = described_class.new(mail)
      expect(message.auto_text).to be_nil
    end
  end

  describe '#auto_html' do
    it 'takes a auto_html with true' do
      mail = mail(auto_html: true)
      message = described_class.new(mail)
      expect(message.auto_html).to be true
    end

    it 'takes a auto_html with false' do
      mail = mail(auto_html: false)
      message = described_class.new(mail)
      expect(message.auto_html).to be false
    end

    it 'does not take an auto_html value' do
      mail = mail()
      message = described_class.new(mail)
      expect(message.auto_html).to be_nil
    end
  end

  describe '#inline_css' do
    it 'takes a inline_css with true' do
      mail = mail(inline_css: true)
      message = described_class.new(mail)
      expect(message.inline_css).to be true
    end

    it 'takes a inline_css with false' do
      mail = mail(inline_css: false)
      message = described_class.new(mail)
      expect(message.inline_css).to be false
    end

    it 'does not take an inline_css value' do
      mail = mail()
      message = described_class.new(mail)
      expect(message.inline_css).to be_nil
    end
  end

  describe '#url_strip_qs'do
    it 'takes a url_strip_qs with true' do
      mail = mail(url_strip_qs: true)
      message = described_class.new(mail)
      expect(message.url_strip_qs).to be true
    end

    it 'takes a url_strip_qs with false' do
      mail = mail(url_strip_qs: false)
      message = described_class.new(mail)
      expect(message.url_strip_qs).to be false
    end

    it 'does not take an url_strip_qs value' do
      mail = mail()
      message = described_class.new(mail)
      expect(message.url_strip_qs).to be_nil
    end
  end

  describe '#preserve_recipients' do
    it 'takes a preserve_recipients with true' do
      mail = mail(preserve_recipients: true)
      message = described_class.new(mail)
      expect(message.preserve_recipients).to be true
    end

    it 'takes a preserve_recipients with false' do
      mail = mail(preserve_recipients: false)
      message = described_class.new(mail)
      expect(message.preserve_recipients).to be false
    end

    it 'does not take preserve_recipients value' do
      mail = mail()
      message = described_class.new(mail)
      expect(message.preserve_recipients).to be_nil
    end
  end

  describe '#view_content_link' do
    it 'takes a view_content_link with true' do
      mail = mail(view_content_link: true)
      message = described_class.new(mail)
      expect(message.view_content_link).to be true
    end

    it 'takes a view_content_link with false' do
      mail = mail(view_content_link: false)
      message = described_class.new(mail)
      expect(message.view_content_link).to be false
    end

    it 'does not take view_content_link value' do
      mail = mail()
      message = described_class.new(mail)
      expect(message.view_content_link).to be_nil
    end
  end

  describe  '#bcc_address' do
    it 'takes a bcc_address' do
      mail = mail(bcc_address: 'bart@simpsons.com')
      message = described_class.new(mail)
      expect(message.bcc_address).to eq('bart@simpsons.com')
    end
  end

  describe '#tracking_domain' do
    it 'takes a tracking_domain' do
      mail = mail(tracking_domain: 'tracking_domain.com')
      message = described_class.new(mail)
      expect(message.tracking_domain).to eq('tracking_domain.com')
    end

    it 'does not take tracking_domain value' do
      mail = mail()
      message = described_class.new(mail)
      expect(message.tracking_domain).to be_nil
    end
  end

  describe '#signing_domain' do
    it 'takes a signing_domain' do
      mail = mail(signing_domain: 'signing_domain.com')
      message = described_class.new(mail)
      expect(message.signing_domain).to eq('signing_domain.com')
    end

    it 'does not take signing_domain value' do
      mail = mail()
      message = described_class.new(mail)
      expect(message.signing_domain).to be_nil
    end
  end

  describe '#return_path_domain' do
    it 'takes a return_path_domain' do
      mail = mail(return_path_domain: 'return_path_domain.com')
      message = described_class.new(mail)
      expect(message.return_path_domain).to eq('return_path_domain.com')
    end

    it 'does not take return_path_domain value' do
      mail = mail()
      message = described_class.new(mail)
      expect(message.return_path_domain).to be_nil
    end
  end

  pending '#merge'
  pending '#global_merge_vars'
  pending '#merge_vars'

  describe '#tags' do
    it 'takes a tag' do
      mail = mail(tags: 'test_tag')
      message = described_class.new(mail)
      expect(message.tags).to eq(['test_tag'])
    end

    it 'takes an array of tags' do
      mail = mail(tags: ['test_tag1', 'test_tag2'])
      message = described_class.new(mail)
      expect(message.tags).to eq(['test_tag1', 'test_tag2'])
    end
  end

  describe '#subaccount' do
    it 'takes a subaccount' do
      mail = mail(subaccount: 'abc123')
      message = described_class.new(mail)
      expect(message.subaccount).to eq('abc123')
    end
  end

  pending '#google_analytics_domains'
  pending '#google_analytics_campaign'
  pending '#metadata'
  pending '#recipient_metadata'
  pending '#attachments'
  pending '#images'

  describe "#to_json" do
    it "returns a proper JSON response for the Mandrill API" do
      mail = mail(body: 'test', from: 'name@domain.tld', headers: {'Reply-To' => 'name1@domain.tld'}, tags: 'test_tag')
      message = described_class.new(mail)
      expect(message.to_json).to include(:from_email, :from_name, :html, :subject, :to, :headers, :tags)
    end
  end
end
