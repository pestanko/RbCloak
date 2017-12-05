# frozen_string_literal: true

require_relative 'rb_cloak/auth'
require_relative 'rb_cloak/realms'

module RbCloak
  # Keycloak client
  class KeycloakClient
    attr_reader :url

    # Initializes the keycloak client
    #
    # @param [String] url url to the keycloak admin console
    # @param [String] username Username
    # @param [String] password Password
    # @param [String] log_level Log level for the keycloak admin client (debug|info|warn|error)
    def initialize(url, username: nil, password: nil, log_level: 'debug')
      @url = url
      Tools::LoggingSupport.set_level(log_level)
      @credentials = {
        username: username,
        password: password,
        grant_type: 'password',
        client_id: 'admin-cli',
      }
    end

    # Gets an authorization module to obtain the access token
    # @return [RbCloak::Auth]
    def auth
      @auth ||= RbCloak::Auth.new(@url, @credentials)
    end

    # Gets a realm manager to be able to access, create, list, or update realms
    # @return [RbCloak::Realm]
    def realms
      @realms ||= RbCloak::Realms.new(self)
    end
  end
end
