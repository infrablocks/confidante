require 'hiera'

class Hiera
  module Backend
    class Env_backend
      def initialize
        Hiera.debug('Hiera environment backend starting')
      end

      def lookup(key, scope, order_override, resolution_type, context)
        Hiera.debug(
            "Looking up #{key} in environment backend with #{resolution_type}")

        Backend.parse_answer(
            ENV[key.to_s.upcase] || throw(:no_such_key),
            scope)
      end
    end
  end
end