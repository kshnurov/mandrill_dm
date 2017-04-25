require 'spec_helper'

describe MandrillDm::DeliveryMethod, 'integrating with the Mail API', integration: true do
  before(:each) do
    Mail.defaults { delivery_method MandrillDm::DeliveryMethod }
  end

  context '#deliver' do
    let(:from_name)       { 'From Name' }
    let(:from_email)      { 'from@domain.tld' }
    let(:from)            { "#{from_name} <#{from_email}>" }
    let(:to)              { (1..3).map { |i| "To #{i} <to_#{i}@domain.tld>" } }
    let(:cc)              { (1..3).map { |i| "Cc #{i} <cc_#{i}@domain.tld>" } }
    let(:bcc)             { (1..3).map { |i| "Bcc #{i} <bcc_#{i}@domain.tld>" } }
    let(:message_subject) { 'Some Message Subject' }
    let(:body)            { 'Some Message Body' }
    let(:content_type)    { 'text/html' }

    let(:api)      { instance_double(Mandrill::API) }
    let(:messages) { instance_double(Mandrill::Messages, send: {}) }

    before(:each) do
      allow(Mandrill::API).to receive(:new).and_return(api)
      allow(api).to receive(:messages).and_return(messages)
    end

    subject do
      example = self
      Mail.deliver do
        from example.from
        to example.to
        cc example.cc
        bcc example.bcc
        subject example.message_subject
        body example.body
        content_type example.content_type
      end
    end

    it 'instantiates the Mandrill API with the configured API key' do
      expect(Mandrill::API).to(
        receive(:new).with(MandrillDm.configuration.api_key).and_return(api)
      )

      subject
    end

    it 'successfully sends a message' do
      allow(Mandrill::API).to receive(:new).and_call_original

      expect { subject }.not_to raise_error
    end

    context 'the sent message' do
      it 'contains the provided from address' do
        expect(messages).to(
          receive(:send).with(
            hash_including(from_name: from_name, from_email: from_email),
            false,
            nil,
            nil
          )
        )

        subject
      end

      %w[to cc bcc].each do |recipient_type|
        it 'contains the provided #{recipient_type} addresses' do
          expect(messages).to receive(:send) do |message_hash|
            (1..3).each do |i|
              expected_recipient = {
                email: "#{recipient_type}_#{i}@domain.tld",
                name:  "#{recipient_type.capitalize} #{i}",
                type:  recipient_type
              }
              expect(message_hash[:to]).to include(expected_recipient)
            end
          end

          subject
        end
      end

      it 'contains the provided subject' do
        expect(messages).to receive(:send).with(
          hash_including(subject: message_subject),
          false,
          nil,
          nil
        )

        subject
      end

      it 'contains the provided body as HTML' do
        expect(messages).to receive(:send).with(
          hash_including(html: body),
          false,
          nil,
          nil
        )

        subject
      end
    end
  end
end
