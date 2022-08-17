# frozen_string_literal: true

require 'hiera'
require 'vault'

class Hiera
  module Backend
    # rubocop:disable Naming/ClassAndModuleCamelCase
    class Vault_backend
      def initialize
        Hiera.debug('Hiera vault backend starting')
      end

      def lookup(key, scope, _order_override, resolution_type, _context)
        Hiera.debug("Looking up #{key} in vault backend " \
                    "with #{resolution_type}")

        vault_config = Backend.parse_answer(Config[:vault], scope)
        vault_address = vault_config[:address]
        vault_client = Vault::Client.new(address: vault_address)

        source = vault_config[:sources][0]

        throw(:unsupported_secrets_engine) unless source[:engine] == 'kv'

        value = read_kv_value(vault_client, source, key)

        Backend.parse_answer(value, scope)
      end

      def read_kv_value(vault_client, source, key)
        secret = vault_client.kv(source[:mount]).read(key)
        throw(:no_such_key) unless secret

        value = secret.data[:value]
        throw(:no_such_key) unless value
        value
      end
    end

    # rubocop:enable Naming/ClassAndModuleCamelCase
  end
end
