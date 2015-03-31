Gem::Specification.new do |s|
  s.name = 'mandrill_dm'
  s.version = '1.2.0'
  s.date = '2015-03-31'
  s.summary = 'A basic Mandrill delivery method for Rails.'
  s.description = 'An easy way to transition from the SMTP delivery method ' \
                  "in Rails to Mandrill's API, while still using ActionMailer."
  s.authors = 'Jonathan Berglund'
  s.email = 'jonathan.berglund@gmail.com'
  s.homepage = 'http://github.com/jlberglund/mandrill_dm'
  s.license = 'MIT'

  s.files = Dir['{lib,spec}/**/*', '[A-Z]*'] - ['Gemfile.lock']
  s.require_path = 'lib'

  s.add_dependency 'mandrill-api', '~> 1.0.53'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'mail'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'travis-lint'
  s.add_development_dependency 'rubocop'
end
