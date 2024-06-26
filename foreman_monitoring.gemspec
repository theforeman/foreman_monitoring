# frozen_string_literal: true

require File.expand_path('lib/foreman_monitoring/version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'foreman_monitoring'
  s.version     = ForemanMonitoring::VERSION
  s.authors     = ['Timo Goebel']
  s.email       = ['timo.goebel@dm.de']
  s.homepage    = 'https://github.com/theforeman/foreman_monitoring'
  s.summary     = 'Foreman plugin for monitoring system integration.'
  s.description = 'Foreman plugin for monitoring system integration.'
  s.license = 'GPL-3.0'

  s.files = Dir['{app,config,db,lib,locale}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_development_dependency 'rdoc'
  s.add_dependency 'deface', '< 2.0'

  s.required_ruby_version = '>= 2.7', '< 4'
end
