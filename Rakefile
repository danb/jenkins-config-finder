require "bundler/gem_tasks"
require "rdoc/task"
require "yard"
require 'yard/rake/yardoc_task'

Rake::RDocTask.new do |rd|
  rd.rdoc_dir = 'doc/rdocs'
  rd.main = 'README.md'
  rd.rdoc_files.include 'README.md', "bin/**/*\.rb", "lib/**/*\.rb" 
  
  rd.options << '--line-numbers'
  rd.options << '--all'
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']   # optional
  t.stats_options = ['--list-undoc']         # optional
end
