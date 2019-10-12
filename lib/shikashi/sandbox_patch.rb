require 'shikashi'

module Shikashi
  module SandboxPatch
    def timeout(*args, &block)
      ::Timeout.timeout(*args, &block)
    end
  end
end

Shikashi::Sandbox.include(Shikashi::SandboxPatch)
