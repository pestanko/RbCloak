# frozen_string_literal: true

require_relative 'rb_cloak/auth'
require_relative 'rb_cloak/realms'

module RbCloak
  class KeycloakClient
    attr_reader :url

    def initialize(url, username, password, log_level: 'debug')
      @url = url
      Tools::LoggingSupport.set_level(log_level)
      @credentials = {
        username: username,
        password: password,
        grant_type: 'password',
        client_id: 'admin-cli',
      }
    end

    def auth
      @auth ||= RbCloak::Auth.new(@url, @credentials)
    end

    def realms
      @realms ||= RbCloak::Realms.new(self)
    end
  end
end
