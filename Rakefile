require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require "yard"
require 'yard/rake/yardoc_task'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']   # optional
  t.stats_options = ['--list-undoc']         # optional
end

RSpec::Core::RakeTask.new

task :default => :spec