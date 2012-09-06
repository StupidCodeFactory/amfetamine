# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "amfetamine/version"

Gem::Specification.new do |s|
  s.name        = "amfetamine"
  s.version     = Amfetamine::VERSION
  s.authors     = ["Timon Vonk"]
  s.email       = ["timon@exvo.com"]
  s.homepage    = "http://www.github.com/exvo/amfetamine"
  s.summary     = %q{REST object abstraction on steroids the makes shit go boom!}
  s.description = %q{Provides an interface to REST apis with objects and a cache. Zero effort!}

  s.rubyforge_project = "amfetamine"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Development dependencies
  s.add_development_dependency "rspec"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-bundler"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "ruby_gntp"
  s.add_development_dependency "httparty"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "simplecov-rcov"
  s.add_development_dependency "pry"


  # Runtime dependencies
  s.add_runtime_dependency "dalli"
  s.add_runtime_dependency "activesupport" # For helper methods
  s.add_runtime_dependency "activemodel" # For validations and AM like behaviour
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "rake"
end
