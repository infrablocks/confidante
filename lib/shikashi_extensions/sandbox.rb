# frozen_string_literal: true

require 'shikashi'

module ShikashiExtensions
  module Sandbox
    def timeout(...)
      ::Timeout.timeout(...)
    end
  end
end

Shikashi::Sandbox.include(ShikashiExtensions::Sandbox)
