require 'hiera'
require 'active_support'
require 'active_support/core_ext/hash/keys'

module Confidante
  class Configuration
    def initialize(opts)
      options = {
          overrides: {},
          scope: {},
      }.merge(opts.to_options)

      unless options[:hiera]
        options[:hiera] = Hiera.new(config: 'config/hiera.yaml')
      end

      @overrides = options[:overrides]
      @scope = options[:scope]
      @hiera = options[:hiera]
    end

    def for_overrides(overrides)
      Configuration.new(
          overrides: overrides,
          scope: @scope,
          hiera: @hiera)
    end

    def for_scope(scope)
      Configuration.new(
          overrides: @overrides,
          scope: scope,
          hiera: @hiera)
    end

    def method_missing(method, *args, &block)
      @hiera.lookup(
          method.to_s,
          nil,
          {cwd: Dir.pwd}
              .merge(@scope)
              .merge({overrides: @overrides}))
    end
  end
end