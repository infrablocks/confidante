require 'confidante/version'
require 'confidante/converters'
require 'confidante/configuration'

require 'hiera/backend/env_backend'
require 'hiera/backend/overrides_backend'

module Confidante
  def self.configuration(opts = {})
    Confidante::Configuration.new(opts)
  end
end
