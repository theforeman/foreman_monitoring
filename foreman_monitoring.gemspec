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
  s.add_development_dependency 'rubocop', '~> 0.71.0'
  s.add_dependency 'deface', '< 2.0'
end
