# frozen_string_literal: true

require 'hiera'
require 'active_support'
require 'active_support/core_ext/hash/keys'

require_relative 'converters'

module Confidante
  class Configuration
    def initialize(opts = {})
      options = opts.to_options

      @overrides = default_overrides(options[:overrides])
      @scope = default_scope(options[:scope])
      @hiera = default_hiera(options[:hiera])
      @converters = default_converters(options[:converters])
    end

    def for_overrides(overrides)
      Configuration.new(
        overrides:,
        scope: @scope,
        hiera: @hiera,
        converters: @converters
      )
    end

    def for_scope(scope)
      Configuration.new(
        overrides: @overrides,
        scope:,
        hiera: @hiera,
        converters: @converters
      )
    end

    def method_missing(method, *_args)
      scope =
        { 'cwd' => Dir.pwd }
        .merge(@scope.stringify_keys)
        .merge({ 'overrides' => @overrides.to_h.stringify_keys })
      @converters.inject(@hiera.lookup(method.to_s, nil, scope)) do |v, c|
        c.convert(v)
      end
    end

    def respond_to_missing?(_method_name, _include_private = false)
      true
    end

    private

    def default_overrides(overrides)
      overrides || {}
    end

    def default_scope(scope)
      scope || {}
    end

    def default_hiera(hiera)
      hiera || Hiera.new(config: 'config/hiera.yaml')
    end

    def default_converters(converters)
      converters || [Confidante::Converters::EvaluatingConverter.new]
    end
  end
end
