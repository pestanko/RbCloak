# frozen_string_literal: true

require_relative 'keycloak_admin/auth'
require_relative 'keycloak_admin/realms'

module KeycloakAdmin
  class Client
    attr_reader :url

    def initialize(url, username, password)
      @url = url
      @credentials = {
        username: username,
        password: password,
        grant_type: 'password',
        client_id: 'admin-cli'
      }
    end

    def auth
      @auth ||= KeycloakAdmin::Auth.new(@url, @credentials)
    end

    def realms
      @realms ||= KeycloakAdmin::Realms.new(self)
    end
  end
end
