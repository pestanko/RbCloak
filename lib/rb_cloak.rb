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
    # @param [bool]   fail Throw an exception on any bad request
    def initialize(url, username: nil, password: nil,
                   client_id: nil, client_secret: nil, log_level: 'debug', fail: false)
      @url = url
      Tools::LoggingSupport.set_level(log_level)
      @credentials = if username
                       user_credentials(username, password)
                     else
                       service_credentials(client_id, client_secret)
                     end
      @fail = fail
    end

    def fail_on_bad_request?
      @fail
    end

    # Gets an authorization module to obtain the access token
    #
    # @return [RbCloak::Auth]
    def auth
      @auth ||= RbCloak::Auth.new(@url, @credentials, realm: 'master')
    end

    # Gets a realm manager to be able to access, create, list, or update realms
    #
    # @return [RbCloak::Realm]
    def realms
      @realms ||= RbCloak::Realms.new(self)
    end

    private

    def user_credentials(username, password)
      {
        username: username,
        password: password,
        grant_type: 'password',
        client_id: 'admin-cli',
      }
    end

    def service_credentials(id, secret)
      {
        client_id: id,
        client_secret: secret,
        grant_type: 'client_credentials',
      }
    end
  end
end
