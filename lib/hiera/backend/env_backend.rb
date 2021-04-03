# frozen_string_literal: true

require 'hiera'

class Hiera
  module Backend
    # rubocop:disable Naming/ClassAndModuleCamelCase
    class Env_backend
      def initialize
        Hiera.debug('Hiera environment backend starting')
      end

      def lookup(key, scope, _order_override, resolution_type, _context)
        Hiera.debug(
          "Looking up #{key} in environment backend with #{resolution_type}"
        )

        Backend.parse_answer(
          ENV[key.to_s.upcase] || throw(:no_such_key),
          scope
        )
      end
    end
    # rubocop:enable Naming/ClassAndModuleCamelCase
  end
end
