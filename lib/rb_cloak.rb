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
    # @param [String] log_level Log level for the keycloak admin client (debug|info|warn|error)
    # @param [Symbol] flow Authentication flow, default is :DirectAccessFlow
    # @param [bool]   fail Throw an exception on any bad request
    # @param [Auth::AuthToken]  auth_token Authentication token, (optional, credentials not required)
    # @option credentials [String] username Username
    # @option credentials [String] password Password
    # @option credentials [String] client_id Client id
    # @option credentials [String] client_secret Client secret
    def initialize(url, log_level: 'debug', fail: false, flow: nil, auth_token: nil, **credentials)
      @auth_token  = auth_token
      @url         = url
      @credentials = credentials
      @flow        = flow || select_flow
      Tools::LoggingSupport.set_level(log_level)
      @fail = fail
    end

    def auth_token(flow = nil, url: nil, realm: 'master', **credentials)
      url  ||= @url
      flow ||= select_flow
      Auth.auth_token(flow, url, realm: realm, **credentials)
    end

    def fail_on_bad_request?
      @fail
    end

    # Gets an authorization module to obtain the access token
    #
    # @return [RbCloak::Auth]
    def auth
      @auth_token ||= auth_token(@flow, realm: 'master', **@credentials)
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
      }
    end

    def service_credentials(id, secret)
      {
        client_id:     id,
        client_secret: secret,
      }
    end

    def select_flow
      if @credentials[:client_secret] && @credentials[:client_id]
        :DirectAccessFlowClient
      else
        :DirectAccessFlowUser
      end
    end
  end
end
