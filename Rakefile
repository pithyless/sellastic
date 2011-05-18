require 'rake'
require 'rake/testtask'

namespace :db do
  task :migrate do
    `sequel -m db/migrations postgres://sellastic@localhost/sellastic_development`
  end

  task :seed do
    ruby 'db/seed.rb'
  end

  namespace :test do
    task :prepare do
      ENV['RACK_ENV'] = 'test'
      `sequel -m db/migrations postgres://sellastic@localhost/sellastic_test`
    end
  end
end

desc 'Run all our tests'
task :test do
  Rake::TestTask.new do |t|
    t.libs << 'test'
    t.pattern = "test/**/*_test.rb"
    t.verbose = false
  end
end

task :default => :test
