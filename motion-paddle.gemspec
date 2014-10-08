# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'motion-paddle/version'

Gem::Specification.new do |spec|
  spec.name          = 'motion-paddle'
  spec.version       = MotionPaddle::VERSION
  spec.authors       = ['Eric Henderson']
  spec.email         = ['henderea@gmail.com']
  spec.description   = %q{A RubyMotion gem for using the Paddle selling framework.}
  spec.summary       = %q{A RubyMotion gem for using the Paddle framework}
  spec.homepage      = 'https://github.com/henderea/motion-paddle'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.3'
end
