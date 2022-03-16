# Mandrill DM

[![Build Status](https://travis-ci.org/spovich/mandrill_dm.svg?branch=master)](https://travis-ci.org/spovich/mandrill_dm)
[![Gem Version](https://badge.fury.io/rb/mandrill_dm.svg)](http://badge.fury.io/rb/mandrill_dm)
[![security](https://hakiri.io/github/spovich/mandrill_dm/master.svg)](https://hakiri.io/github/spovich/mandrill_dm/master)
[![Code Climate](https://codeclimate.com/github/spovich/mandrill_dm/badges/gpa.svg)](https://codeclimate.com/github/spovich/mandrill_dm)

Mandrill DM allows you to use ActionMailer with the Mandrill API. Created by [Jonathan Berglund](https://github.com/jlberglund)
and maintained by [John Dell](https://github.com/spovich), and [Kirill Shnurov](https://github.com/kshnurov) and various [contributors](https://github.com/spovich/mandrill_dm/graphs/contributors).

## !!! MIGRATE from Mandrill IMMEDIATELY!

On 15.03.2022 Mailchimp blocked tens of thousands of accounts for one reason: their nationality.
There's no law that required that. [See the email](https://github.com/kshnurov/mandrill_dm/blob/master/mailchimp_email.png)

They didn't give any prior notice, time to migrate, or an option to download our data and email lists.
We're unable to log in despite using Mailchimp & Mandrill for 8 years and an excellent account score.

WE'VE LOST ALL OUR DATA and our operations were disrupted.

Mailchimp's actions are completely unlawful, violate business ethics and moral norms.
This is pure racism and Nazism. It should not be tolerated.

We urge you to MIGRATE to other services IMMEDIATELY until your account is blocked because of your race, sex, nationality, or T-shirt color.

This gem will continue to work, but will log error on every sent message.

You're free to fork it and keep using Mandrill if you support punishing innocent people for being born in a particular country,
no matter what they think about their government and recent events.

## Rails Setup

First, add the gem to your Gemfile and run the `bundle` command to install it.

```ruby
gem 'mandrill_dm'
```

Second, set the delivery method in `config/environments/production.rb`.

```ruby
config.action_mailer.delivery_method = :mandrill
```

Third, create an initializer such as `config/initializers/mandrill.rb` and paste in the following code:

```ruby
MandrillDm.configure do |config|
  config.api_key = ENV['MANDRILL_APIKEY']
  # config.async = false
end
```

NOTE: If you don't already have an environment variable for your Mandrill API key, don't forget to create one.

**Rails 3**: see [Rails 3 (Mail 2.5) support](https://github.com/spovich/mandrill_dm/wiki/Rails-3-(Mail-2.5)-support)

### Available configuration options

Option     | Default value     | Description
-----------|-------------------|------------------------------------------------------------
`api_key`  |                   | Mandrill API key.
`async`    | `false`           | Enable a background sending mode that is optimized for bulk sending.

### Mandrill Templates

If you want to use this gem with mandrill templates you just have to add the `template` param to the `mail` function and set the `body` param to empty string `''`.

> We use `template` instead of `template_name` as described in mandrill documentation since `template_name` it's used by [ActionMailer](http://api.rubyonrails.org/classes/ActionMailer/Base.html).

```ruby
class MyMailer < ActionMailer::Base
  def notify_user(email)
    headers['Reply-To'] = 'your.friend@email.com'
    mail(
      to: email,
      from: 'your@email.com',
      body: '',
      template: 'your-mandrill-template-slug',
      template_content: [ # optional
        {
          name: 'header', # the name of the mc:edit editable region to inject into
          content: 'string to replace a mc:edit="header" in your template', # the content to inject
        },
        {
          name: 'content',
          content: 'string to replace a mc:edit="content" in your template'
        }
      ]
    )
  end
end
```

## Development & Feedback

Questions or problems? Please use the issue tracker. If you would like to contribute to this project, fork this repository. Pull requests appreciated! Please ensure all specs and rubocop checks pass locally (run `rake`) and
verify the travis build matrix passes.

This gem was inspired by the [letter_opener](https://github.com/ryanb/letter_opener/) and [mandrill-delivery-handler](https://github.com/earnold/mandrill-delivery-handler) gems. Special thanks to the folks at MailChimp and Mandrill for their Starter service and [Ruby API](https://bitbucket.org/mailchimp/mandrill-api-ruby).

### Interactive Usage
  $ irb -I . -r 'lib/mandrill_dm'
  > require 'pry'
