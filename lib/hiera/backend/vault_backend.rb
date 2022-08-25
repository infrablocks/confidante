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

        throw :no_vault_address_provided unless vault_address

        vault_client = Vault::Client.new(address: vault_address)
        value = get_value(vault_client, key, vault_config[:sources])
        Backend.parse_answer(value, scope)
      end

      def get_value(vault_client, key, sources)
        found_source = sources.find do |source|
          read_kv_value(vault_client, source, key)
        end

        throw(:no_such_key) unless found_source

        read_kv_value(vault_client, found_source, key)
      end

      def read_kv_value(vault_client, source, key)
        throw(:unsupported_secrets_engine) unless source[:engine] == 'kv'

        mount = source[:mount]
        full_path = "#{source[:path]}/#{key}"

        secret = vault_client.kv(mount).read(full_path)
        return nil unless secret

        secret.data[:value]
      end
    end

    # rubocop:enable Naming/ClassAndModuleCamelCase
  end
end
