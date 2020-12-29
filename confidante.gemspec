# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'confidante/version'
require 'date'

Gem::Specification.new do |spec|
  spec.name = 'confidante'
  spec.version = Confidante::VERSION
  spec.authors = ['Toby Clemson']
  spec.email = ['tobyclemson@gmail.com']

  spec.date = Date.today.to_s
  spec.summary = 'A configuration engine over hiera.'
  spec.description =
      'A configuration engine combining environment variables, programmatic ' +
          'overrides and the power of hiera.'
  spec.homepage = 'https://github.com/infrablocks/confidante'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r{^(bin|lib|CODE_OF_CONDUCT\.md|confidante\.gemspec|Gemfile|LICENSE\.txt|Rakefile|README\.md)})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6.0'

  spec.add_dependency 'hiera', '~> 3.3', '>= 3.3.1'
  spec.add_dependency 'activesupport', '>= 4'
  spec.add_dependency 'shikashi', '~> 0.6'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rake_circle_ci', '~> 0.3'
  spec.add_development_dependency 'rake_github', '~> 0.3'
  spec.add_development_dependency 'rake_ssh', '~> 0.2'
  spec.add_development_dependency 'rake_gpg', '~> 0.12'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'gem-release', '~> 2.0'
end
