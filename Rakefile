require 'rake/testtask'

desc 'Run tests'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']  
end

desc 'Build the gem'
task :build do
  gemspec_path = Dir['*.gemspec'].first
  spec = eval(File.read(gemspec_path))

  `gem build #{gemspec_path}`
end

task :default => :test
