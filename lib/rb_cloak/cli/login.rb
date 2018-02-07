# frozen_string_literal: true

require_relative 'commands'
require_relative 'rbcloak_wrapper'

module RbCloak
  module Cli
    class LoginCommand < AbstractCommand
      option ['-u', '--username'], 'USERNAME', 'Username for the keycloak', required: true
      option ['-p', '--password'], 'PASSWORD', 'Password for the keycloak', reauired: true
      option ['-U', '--url'], 'URL', 'Url for the keycloack', default: 'http://localhost:8080/'

      def execute
        RbCloakWrapper.instance.credentials url:      url,
                                            username: username,
                                            password: password
      end
    end

    class LogoutCommand < AbstractCommand
      def execute
        RbCloakWrapper.instance.credentials url: nil,
                                            username: nil,
                                            password: nil
      end
    end
  end
end
