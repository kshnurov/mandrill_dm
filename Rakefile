require 'bundler'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

Bundler.require(:default, :development)

task default: :spec
RSpec::Core::RakeTask.new

directory 'tmp/coverage'
desc 'Generates spec coverage results'
task :coverage do
  ENV['COVERAGE'] = '1'
  Rake::Task[:spec].invoke
  ENV['COVERAGE'] = nil
  `open tmp/coverage/index.html` if RUBY_PLATFORM['darwin']
end

desc 'Validate Travis CI configuration'
task :validate do
  print ' Travis CI Validation '.center(80, '*') + "\n"
  result = `travis-lint #{File.expand_path('../.travis.yml', __FILE__)}`
  puts result.empty? ? 'OK' : result
  print '*' * 80 + "\n"
  raise 'Travis CI validation failed' unless result.empty?
end

