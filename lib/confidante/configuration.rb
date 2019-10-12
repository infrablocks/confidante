require 'hiera'
require 'active_support'
require 'active_support/core_ext/hash/keys'

require_relative 'converters'

module Confidante
  class Configuration
    def initialize(opts = {})
      options = {
          overrides: {},
          scope: {},
      }.merge(opts.to_options)

      unless options[:hiera]
        options[:hiera] = Hiera.new(config: 'config/hiera.yaml')
      end

      unless options[:converters]
        options[:converters] =
            [Confidante::Converters::EvaluatingConverter.new]
      end

      @overrides = options[:overrides]
      @scope = options[:scope]
      @hiera = options[:hiera]
      @converters = options[:converters]
    end

    def for_overrides(overrides)
      Configuration.new(
          overrides: overrides,
          scope: @scope,
          hiera: @hiera,
          converters: @converters)
    end

    def for_scope(scope)
      Configuration.new(
          overrides: @overrides,
          scope: scope,
          hiera: @hiera,
          converters: @converters)
    end

    def method_missing(method, *args, &block)
      scope =
          {'cwd' => Dir.pwd}
              .merge(@scope.stringify_keys)
              .merge({'overrides' => @overrides.to_h.stringify_keys})
      @converters.inject(@hiera.lookup(method.to_s, nil, scope)) do |v, c|
        c.convert(v)
      end
    end
  end
end