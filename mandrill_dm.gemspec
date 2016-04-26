Gem::Specification.new do |s|
  s.name = 'mandrill_dm'
  s.version = '1.3.0'
  s.date = '2016-04-25'
  s.summary = 'A basic Mandrill delivery method for Rails.'
  s.description = 'A basic Mandrill delivery method for Rails.'
  s.authors = ['Jonathan Berglund', 'John Dell', 'Kirill Shnurov']
  s.email = ['jonathan.berglund@gmail.com', 'spovich@gmail.com']
  s.homepage = 'http://github.com/spovich/mandrill_dm'
  s.license = 'MIT'

  s.files = Dir['{lib,spec}/**/*', '[A-Z]*'] - ['Gemfile.lock']
  s.require_path = 'lib'

  s.add_dependency 'mandrill-api',            '~> 1.0.53'

  s.add_development_dependency 'rspec',       '~> 3.4'
  s.add_development_dependency 'mail',        '~> 2.6'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'simplecov',   '~> 0.11'
  s.add_development_dependency 'rubocop',     '~> 0.39'
  s.add_development_dependency 'pry'
end
