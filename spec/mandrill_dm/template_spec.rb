require 'spec_helper'

describe MandrillDm::Template do
  describe '#name' do
    it 'takes a template_name with true' do
      mail = new_mail(template_name: 'test template name')
      template = described_class.new(mail)
      expect(template.name).to eq('test template name')
    end

    it 'does not take an template_name value' do
      mail = new_mail
      template = described_class.new(mail)
      expect(template.name).to be_nil
    end
  end

  describe '#content' do
    it 'takes an array of template_content' do
      template_content = [
        {
          'name' => 'test name',
          'content' => 'test content'
        }
      ]
      mail = new_mail(template_content: template_content)
      template = described_class.new(mail)
      expect(template.content).to eq(template_content)
    end

    it 'does not take template_content value' do
      mail = new_mail
      template = described_class.new(mail)
      expect(template.content).to eq([])
    end
  end
end
