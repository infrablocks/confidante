# frozen_string_literal: true

require 'hiera'
require 'vault'

class Hiera
  module Backend
    # rubocop:disable Naming/ClassAndModuleCamelCase
    class Vault_backend
      def initialize
        Hiera.debug('Hiera vault backend starting')

        @client = Vault::Client.new
      end

      def lookup(key, scope, _order_override, resolution_type, _context)
        Hiera.debug("Looking up #{key} in vault backend " \
                    "with #{resolution_type}")

        secret = @client.kv('kv').read(key)
        throw(:no_such_key) unless secret

        value = secret.data[:value]
        throw(:no_such_key) unless value

        Backend.parse_answer(value, scope)
      end
    end
    # rubocop:enable Naming/ClassAndModuleCamelCase
  end
end
