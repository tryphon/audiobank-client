# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'audiobank/client/version'

Gem::Specification.new do |gem|
  gem.name          = "audiobank-client"
  gem.version       = Audiobank::Client::VERSION
  gem.authors       = ["Alban Peignier", "Florent Peyraud"]
  gem.email         = ["alban@tryphon.eu", "florent@tryphon.eu" ]
  gem.description   = %q{Manage AudioBank documents from command-line or Ruby}
  gem.summary       = %q{AudioBank API client}
  gem.homepage      = "http://projects.tryphon.eu/projects/audiobank-client"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "httparty"
  gem.add_runtime_dependency "activesupport", "< 4"
  gem.add_runtime_dependency "json"
  gem.add_runtime_dependency "virtus"
  gem.add_runtime_dependency "null_logger"
  gem.add_runtime_dependency "trollop"
  gem.add_runtime_dependency "progressbar"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "fakeweb"
  gem.add_development_dependency "guard"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "guard-bundler"
end
