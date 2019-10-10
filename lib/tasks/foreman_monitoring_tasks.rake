# frozen_string_literal: true

# Tests
namespace :test do
  desc 'Test ForemanMonitoring'
  Rake::TestTask.new(:foreman_monitoring) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ['test', test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
    t.warning = false
  end
end

namespace :foreman_monitoring do
  task :rubocop do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_foreman_monitoring) do |task|
        task.patterns = ["#{ForemanMonitoring::Engine.root}/app/**/*.rb",
                         "#{ForemanMonitoring::Engine.root}/lib/**/*.rb",
                         "#{ForemanMonitoring::Engine.root}/test/**/*.rb"]
      end
    rescue StandardError
      puts 'Rubocop not loaded.'
    end

    Rake::Task['rubocop_foreman_monitoring'].invoke
  end
end

Rake::Task[:test].enhance ['test:foreman_monitoring']

load 'tasks/jenkins.rake'
Rake::Task['jenkins:unit'].enhance ['test:foreman_monitoring', 'foreman_monitoring:rubocop'] if Rake::Task.task_defined?(:'jenkins:unit')
