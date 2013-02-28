# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rp_clustering-rgeo-activerecord/version'

Gem::Specification.new do |gem|
  gem.name          = "rp_clustering-rgeo-activerecord"
  gem.version       = RPClustering::RGeo::ActiveRecord::VERSION
  gem.authors       = ["Robert Pyke"]
  gem.email         = ["robert.j.pyke@gmail.com"]
  gem.summary       = %q{RGeo PostGIS extension to provide clustering functionality}
  gem.description   = %q{A RGeo PostGIS extension to provide Active Record (Model) clustering functionality}
  gem.homepage      = "https://github.com/robertpyke/rp_clustering-rgeo-activerecord"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.license = 'MIT'

  # Development Dependencies
  gem.add_development_dependency('bundler', '>= 1.0.0')
  gem.add_development_dependency('test-unit', '~> 2.5.4')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('rdoc')
  gem.add_development_dependency('pg')

  # Deployed Gem Dependencies
  gem.add_dependency('activerecord', '~> 3.0')
  gem.add_dependency('arel', '~> 3.0.2')
  gem.add_dependency('rgeo', '~> 0.3.20')
  gem.add_dependency('rgeo-activerecord', '~> 0.4.6')
  # This Gem is specific to postgis
  gem.add_dependency('activerecord-postgis-adapter', '~> 0.5.1')
end
