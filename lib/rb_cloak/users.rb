# frozen_string_literal: true

require 'json'

require_relative 'defaults'
require_relative 'user_client_scope_mappings'

module RbCloak
  # Documentation:
  # * REST: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_users_resource
  class Users < Defaults
    attr_reader :parent

    alias realm parent

    def initialize(client, parent)
      super(client)
      @parent = parent
    end

    def url
      parent.url + '/users'
    end

    def set_password(user_id, password, **params)
      params = {
        value:     password,
        temporary: false,
        type:      'password',
      }.merge(params)

      url = "#{self.url}/#{user_id}/reset-password"
      log.info("Setting password: (PUT #{url})")
      body = JSON.dump(params)
      result = check_request { RestClient.put(url, body, headers) }
      log.debug("Password set response: #{result}")
      result
    end

    def logout(user_id)
      url = "#{self.url}/#{user_id}/logout"
      log.info("Logging out the user: #{url}")
      result = check_request { RestClient.post(url, {}, headers) }
      log.debug("Logout response: #{result}")
      result
    end
  end

  # USER_ENTITY: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_userrepresentation
  class User < Default
    def realm
      client.realm
    end

    def entity_id
      entity[:id]
    end

    def entity_name
      entity[:username]
    end

    def password(passwd, **kwargs)
      client.set_password(entity_id, passwd, **kwargs)
    end

    def logout
      client.logout(entity_id)
    end
  end
  # Service account user entity
  class ServiceAccountUser < User
    def client_role_mappings(client_id)
      RbCloak::UserClientRoleMappings.new(client, self, client_id)
    end
  end
end
