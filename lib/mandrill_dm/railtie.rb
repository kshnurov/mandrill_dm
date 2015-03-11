require 'mandrill_dm'

module MandrillDm
  class Railtie < Rails::Railtie
    initializer 'mandrill_dm.add_delivery_method' do
      ActiveSupport.on_load :action_mailer do
        ActionMailer::Base.add_delivery_method :mandrill, MandrillDm::DeliveryMethod
      end
    end
  end
end
