require 'shikashi'

module ShikashiExtensions
  module Sandbox
    def timeout(*args, &block)
      ::Timeout.timeout(*args, &block)
    end
  end
end

Shikashi::Sandbox.include(ShikashiExtensions::Sandbox)
