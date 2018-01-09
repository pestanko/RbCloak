# frozen_string_literal: true

require_relative 'general_flow'

module RbCloak
  # Auth provider
  module Auth
    class DirectAccessFlow < GeneralFlow
    end
    class DirectAccessFlowClient < DirectAccessFlow
      def credentials
        {
          grant_type: 'client_credentials',
        }.merge(@credentials)
      end
    end

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