# frozen_string_literal: true

require_relative 'general_flow'

module RbCloak
  # Auth provider
  module Auth
    class DirectAccessFlow < GeneralFlow
    end

    # Direct access flow using client_id and secret
    class DirectAccessFlowClient < DirectAccessFlow
      def credentials
        {
          grant_type: 'client_credentials',
        }.merge(@credentials)
      end
    end

    # Direct access flow using username and password
    class DirectAccessFlowUser < DirectAccessFlow
      def credentials
        {
          grant_type: 'password',
          client_id:  'admin-cli',
        }.merge(@credentials)
      end
    end
  end
end