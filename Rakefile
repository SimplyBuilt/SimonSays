require "bundler/gem_tasks"
require "rake/testtask"
require 'rdoc/task'

Rake::TestTask.new :test do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

namespace :docs do
  RDoc::Task.new :generate do |rdoc|
    rdoc.main = "README.doc"
    rdoc.title = "SimonSays RDOC"

    rdoc.rdoc_dir = "docs"
    rdoc.rdoc_files.include("README.md", "lib/**/*.rb")

    rdoc.options << "--all"
  end
end


task :default => :test
