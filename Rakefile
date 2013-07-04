require 'rake/testtask'
require 'rdoc/task'

task :default => [:test]

# Run tests.
task :test do
  Rake::TestTask.new do |t|
    t.pattern = 'test/**/*_test.rb'
  end
end

# Rebuild and reinstall the gem.
task :refresh do
  Rake::Task['doc'].invoke
  
  system 'markup README.md --force'
  
  Dir['*.gem'].each {|file| File.delete file}
  
  system 'gem build *.gemspec'
  system 'gem install *.gem'
end

# Generate documentation.
RDoc::Task.new :doc do |rd|
  rd.rdoc_dir = 'doc'
  rd.rdoc_files.include 'lib/**/*.rb'
end
