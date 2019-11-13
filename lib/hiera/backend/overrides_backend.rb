require 'hiera'

class Hiera
  module Backend
    class Overrides_backend
      def initialize
        Hiera.debug('Hiera overrides backend starting')
      end

      def lookup(key, scope, order_override, resolution_type, context)
        Hiera.debug(
            "Looking up #{key} in overrides backend with #{resolution_type}")

        overrides = scope && scope['overrides']
        Hiera.debug("Found overrides: #{overrides}")

        throw(:no_such_key) unless overrides

        override = overrides[key.to_s]
        Hiera.debug("Found override: #{override} for key: #{key}")

        Backend.parse_answer(override || throw(:no_such_key), scope)
      end
    end
  end
end
