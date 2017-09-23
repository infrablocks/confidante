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

        throw(:no_such_key) unless overrides

        Backend.parse_answer(
            overrides[key.to_s] || throw(:no_such_key),
            scope)
      end
    end
  end
end