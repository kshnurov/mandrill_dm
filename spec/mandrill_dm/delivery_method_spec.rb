require 'spec_helper'

describe MandrillDm::DeliveryMethod do
  before(:each) do
    Mail.defaults do
      delivery_method MandrillDm::DeliveryMethod
    end
  end

  context 'api' do
    before(:each) do
      @api = double('Mandrill::API')
      @api.stub_chain(:messages, :send).and_return({})
    end

    it 'gets instantiated' do
      Mandrill::API.should receive(:new).with('1234567890').and_return(@api)
      Mail.deliver do
        from 'John Doe <name@domain.tld>'
        body 'Hello world!'
        subject 'A Test'
        to 'name@domain.tld'
        bcc 'name@domain.tld'
      end
    end

    it 'sends a message' do
      expect {
        Mail.deliver do
          from 'John Doe <name@domain.tld>'
          body 'Hello world!'
          subject 'A Test'
          to 'name@domain.tld'
          bcc 'name@domain.tld'
        end
      }.not_to raise_error
    end
  end
end
