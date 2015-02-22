Gem::Specification.new do |s|
  s.name = 'mandrill_dm'
  s.version = '1.1.1'
  s.date = '2014-10-24'
  s.summary = "A basic Mandrill delivery method for Rails."
  s.description = "An easy way to transition from the SMTP delivery method in Rails to Mandrill's API, while still using ActionMailer."
  s.authors = "Jonathan Berglund"
  s.email = 'jonathan.berglund@gmail.com'
  s.homepage = "http://github.com/jlberglund/mandrill_dm"
  s.license = 'MIT'

  s.files = Dir["{lib,spec}/**/*", "[A-Z]*"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.add_dependency 'mandrill-api', '~> 1.0.51'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'mail'
end
