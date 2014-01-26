# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pavlov_rss/version'

Gem::Specification.new do |spec|
  spec.name          = "pavlov_rss"
  spec.version       = PavlovRss::VERSION
  spec.authors       = ["Minwoo Lee", "Insu Yun"]
  spec.email         = ["ermaker@gmail.com", "wuninsu@gmail.com"]
  spec.summary       = %q{Pavlov's RSS}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "fakeweb", "~> 1.3"
  spec.add_development_dependency "metric_fu"
end
