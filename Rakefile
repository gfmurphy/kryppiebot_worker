require 'rake/testtask'

desc "Run tests for project"
Rake::TestTask.new('test') do |t|
  t.libs << "test"
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
  t.warning = true
end

task :default => [:test]
