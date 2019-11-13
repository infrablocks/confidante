# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'confidante/version'

Gem::Specification.new do |spec|
  spec.name = 'confidante'
  spec.version = Confidante::VERSION
  spec.authors = ['Toby Clemson']
  spec.email = ['tobyclemson@gmail.com']

  spec.date = '2017-01-27'
  spec.summary = 'A configuration engine over hiera.'
  spec.description =
      'A configuration engine combining environment variables, programmatic ' +
          'overrides and the power of hiera.'
  spec.homepage = 'https://github.com/tobyclemson/confidante'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  spec.add_dependency 'hiera', '~> 3.3', '>= 3.3.1'
  spec.add_dependency 'activesupport', '>= 4.0.2'
  spec.add_dependency 'vault'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'gem-release', '~> 0.7'
end
