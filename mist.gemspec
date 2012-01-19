# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mist/version"

Gem::Specification.new do |s|
  s.name        = "mist"
  s.version     = Mist::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Colin MacKenzie IV"]
  s.email       = ["sinisterchipmunk@gmail.com"]
  s.homepage    = "http://github.com/sinisterchipmunk/mist"
  s.summary     = %q{TODO: summary}
  s.description = %q{TODO: description}

  s.add_dependency 'git',           '~> 1.2.5'
  s.add_dependency 'github-markup', '~> 0.7.0'
  s.add_dependency 'redcarpet',     '~> 2.0.1'
  s.add_dependency 'activegist',    '~> 0.6.0'
  
  s.add_development_dependency 'cucumber-rails',     '~> 1.2.1'
  s.add_development_dependency 'database_cleaner',   '~> 0.7.0'
  s.add_development_dependency 'rspec-rails',        '~> 2.8.1'
  s.add_development_dependency 'factory_girl_rails', '~> 1.5.0'
  s.add_development_dependency 'fakeweb',            '~> 1.3.0'

  s.rubyforge_project = "mist"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
