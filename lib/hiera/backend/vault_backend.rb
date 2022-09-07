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

        if valid_vault_address?(vault_config)
          Hiera.warn('No vault address provided. Skipping lookup!')
          nil
        else
          Backend.parse_answer(get_value(vault_config, key), scope)
        end
      end

      def valid_vault_address?(vault_config)
        vault_address = vault_config[:address]
        vault_address.nil? || vault_address.empty?
      end

      def get_value(vault_config, key)
        vault_address = vault_config[:address]
        vault_client = Vault::Client.new(address: vault_address)
        get_first_value_from_sources(
          vault_client,
          key,
          vault_config[:sources]
        )
      end

      def get_first_value_from_sources(vault_client, key, sources)
        sources.each do |source|
          value = read_kv_value(vault_client, source, key)

          return value if value
        end

        throw(:no_such_key)
      end

      def read_kv_value(vault_client, source, key)
        throw(:unsupported_secrets_engine) unless source[:engine] == 'kv'

        mount = source[:mount]
        full_path = "#{source[:path]}/#{key}"

        Hiera.debug("Looking up #{full_path} at #{mount}")
        secret = vault_client.kv(mount).read(full_path)
        return nil unless secret

        secret.data[:value]
      end
    end

    # rubocop:enable Naming/ClassAndModuleCamelCase
  end
end
