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

        Backend.parse_answer(
            scope[:overrides][key.to_sym] || throw(:no_such_key),
            scope)
      end
    end
  end
end