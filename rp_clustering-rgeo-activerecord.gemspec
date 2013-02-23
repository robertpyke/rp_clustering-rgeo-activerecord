# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rp_clustering-rgeo-activerecord/version'

Gem::Specification.new do |gem|
  gem.name          = "rp_clustering-rgeo-activerecord"
  gem.version       = RpClustering::Rgeo::Activerecord::VERSION
  gem.authors       = ["Robert Pyke"]
  gem.email         = ["robert.j.pyke@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  # Development Dependencies
  gem.add_development_dependency('bundler', '>= 1.0.0')
  gem.add_development_dependency('test-unit', '~> 2.5.4')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('rdoc')

  # Deployed Gem Dependencies
  gem.add_dependency('activerecord', '~> 3.0')
end
