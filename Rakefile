require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new(:spec)
Cucumber::Rake::Task.new(:features) { |t| t.cucumber_opts = "features --format pretty --tags ~@todo" }
task :default => [ :spec, :features ]
