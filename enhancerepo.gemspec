# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)
require 'enhance_repo/version'

Gem::Specification.new do |s|
  s.name        = 'enhancerepo'
  s.version     = EnhanceRepo::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Duncan Mac-Vicar']
  s.email       = ['dmacvicar@suse.de']
  s.homepage    = 'http://en.opensuse.org/Enhancerepo'
  s.summary = 'Tool to add additional information to repomd repositories'
  s.description = 'enhancerepo adds additional metadata to repommd repositories and serves as the testbed for the specification'

  s.required_rubygems_version = '>= 1.3.6'
  # s.rubyforge_project         = ""

  s.add_dependency('rpm')
  s.add_dependency('builder')
  s.add_dependency('nokogiri')
  s.add_dependency('trollop')
  s.add_dependency('log4r')
  s.add_dependency('activesupport')

  s.add_development_dependency('rubocop', '= 0.49.1')
  s.add_development_dependency('bundler', ['>= 1.0.rc.2'])
  s.add_development_dependency('yard', ['>= 0.5'])
  s.add_development_dependency('diffy')
  s.add_development_dependency('equivalent-xml')

  s.files        = Dir.glob('bin/*') + Dir.glob('lib/**/*') + %w[README.md]
  s.require_path = 'lib'

  s.bindir = 'bin'
  s.executables = Dir.glob('bin/*').map { |x| File.basename x }
  s.default_executable = 'enhancerepo'

  s.post_install_message = <<-POST_INSTALL_MESSAGE
  ____
/@    ~-.
\/ __ .- | remember to have fun!
 // //  @

  POST_INSTALL_MESSAGE
end
