# frozen_string_literal: true

require 'hiera'

class Hiera
  module Backend
    # rubocop:disable Naming/ClassAndModuleCamelCase
    class Vault_backend
      def initialize
        Hiera.debug('Hiera vault backend starting')
      end

      def lookup(key, scope, _order_override, resolution_type, _context); end
    end
    # rubocop:enable Naming/ClassAndModuleCamelCase
  end
end
