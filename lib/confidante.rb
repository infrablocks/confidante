# frozen_string_literal: true

require_relative 'confidante/version'
require_relative 'confidante/converters'
require_relative 'confidante/configuration'

require_relative 'shikashi_extensions/sandbox'

require_relative 'hiera/backend/env_backend'
require_relative 'hiera/backend/overrides_backend'
require_relative 'hiera/backend/vault_backend'

module Confidante
  def self.configuration(opts = {})
    Confidante::Configuration.new(opts)
  end
end
