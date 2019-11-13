require 'hiera'
require 'vault'

class Hiera
  module Backend
    class Vault_backend
      def initialize
        Hiera.debug('Hiera vault backend starting')
        address = Config[:vault][:address]
        @client = self.login address
      end

      def login(address)
        begin
          client = Vault::Client.new(address: address)
          client.auth_token.lookup_self
          return client
        rescue
          system("vault login -method=oidc role=developer")
          return Vault::Client.new(address: address)
        end
      end

      def lookup(key, scope, order_override, resolution_type, context)
        Hiera.debug(
            "Looking up #{key} in vault backend with #{resolution_type}")
        vault_store = scope['vault_store']

        puts
        puts key
        puts
        puts scope
        puts

        begin
          data = @client
                     .logical
                     .read(vault_store)
                     .data

          Backend.parse_answer(
              data[key.to_sym].to_s || throw(:no_such_key),
              scope)
        rescue Vault::VaultError
          Backend.parse_answer(
              throw(:vault_error),
              scope)
        end
      end
    end
  end
end

