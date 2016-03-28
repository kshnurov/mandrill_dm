require 'bundler'
require 'bundler/gem_tasks'
Bundler.require(:default, :development)

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: %w(all_checks)

desc 'Run all specs and rubocop checks'
task :all_checks do
  Rake::Task['spec'].invoke
  Rake::Task['rubocop'].invoke
end

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
