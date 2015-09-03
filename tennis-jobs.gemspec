# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "tennis-jobs"
  spec.version       = "0.3.0"
  spec.authors       = ["Nicolas ZERMATI"]
  spec.email         = ["nicoolas25@gmail.com"]

  spec.summary       = %q{A small background job library on top of sneakers.}
  spec.description   = %q{A small background job library on top of sneakers.}
  spec.homepage      = "https://github.com/nicoolas25/tennis"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sneakers"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "codeclimate-test-reporter"
end
