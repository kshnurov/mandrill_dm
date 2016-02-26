require 'spec_helper'

describe MandrillDm::DeliveryMethod do
  let(:options)         { { 'some_option_key' => 'some option value' } }
  let(:delivery_method) { MandrillDm::DeliveryMethod.new(options) }

  context '#initialize' do
    it 'sets passed options to `settings` attr_accesor' do
      expect(delivery_method.settings).to eql(options)
    end
  end

  context '#deliver!' do
    let(:mail_message) { instance_double(Mail::Message) }
    let(:api_key)      { '1234567890' }
    let(:async)        { false }
    let(:dm_message)   { instance_double(MandrillDm::Message) }
    let(:response)     { { 'some_response_key' => 'some response value' } }
    let(:msgs_methods) { { send: response, send_template: response } }
    let(:messages)     { instance_double(Mandrill::Messages, msgs_methods) }
    let(:api)          { instance_double(Mandrill::API, messages: messages) }

    before(:each) do
      allow(Mandrill::API).to receive(:new).and_return(api)
      allow(dm_message).to receive(:template).and_return(nil)
      allow(MandrillDm).to receive_message_chain(
        :configuration,
        :api_key
      ).and_return(api_key)
      allow(MandrillDm).to receive_message_chain(:configuration, :async).and_return(async)
      allow(MandrillDm::Message).to receive(:new).and_return(dm_message)
      allow(dm_message).to receive(:send_at).and_return(nil)
    end

    subject { delivery_method.deliver!(mail_message) }

    it 'instantiates the Mandrill API with the configured API key' do
      expect(Mandrill::API).to receive(:new).with(api_key).and_return(api)

      subject
    end

    it 'creates a Mandrill message from the Mail message' do
      expect(MandrillDm::Message).to(
        receive(:new).with(mail_message).and_return(dm_message)
      )

      subject
    end

    it 'sends the JSON version of the Mandrill message via the API' do
      allow(dm_message).to receive(:to_json).and_return('Some message JSON')
      expect(messages).to receive(:send).with('Some message JSON', false, nil, nil)

      subject
    end

    it 'returns the response from sending the message' do
      expect(subject).to eql(response)
    end

    it 'establishes the response for subsequent use' do
      subject

      expect(delivery_method.response).to eql(response)
    end

    describe 'with a send_at time' do
      before(:each) do
        allow(dm_message).to receive(:send_at).and_return("2016-08-08 18:36:25")
      end

      it 'instantiates the Mandrill API with the configured API key' do
        expect(Mandrill::API).to receive(:new).with(api_key).and_return(api)

        subject
      end

      it 'creates a Mandrill message from the Mail message' do
        expect(MandrillDm::Message).to(
          receive(:new).with(mail_message).and_return(dm_message)
        )

        subject
      end

      it 'sends the JSON version of the Mandrill message via the API' do
        allow(dm_message).to receive(:to_json).and_return('Some message JSON')
        expect(messages).to receive(:send).with('Some message JSON', false, nil, "2016-08-08 18:36:25")
        subject
      end
    end


    describe 'with template' do
      let!(:template_slug) { 'some-template-slug' }
      let!(:html) { '<some>html</some>' }
      let!(:message_json) { { html: html } }

      before(:each) do
        allow(dm_message).to receive(:to_json).and_return(message_json)
        allow(dm_message).to receive(:template).and_return(template_slug)
        allow(dm_message).to receive(:template_content).and_return(
          [
            name: 'body',
            content: html
          ]
        )
      end

      it 'sends the JSON version of the Mandrill Template message via the API' do
        template_content = [{
          name: 'body',
          content: html
        }]

        expect(messages).to(
          receive(:send_template).with(
            template_slug,
            template_content,
            message_json,
            async
          )
        )

        subject
      end

      it 'returns the response from sending the message' do
        expect(subject).to eql(response)
      end

      it 'establishes the response for subsequent use' do
        subject

        expect(delivery_method.response).to eql(response)
      end
    end
  end
end
