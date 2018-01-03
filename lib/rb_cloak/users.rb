# frozen_string_literal: true

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
  end

  # USER_ENTITY: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_userrepresentation
  class User < Default
    def entity_id
      entity[:id]
    end

    def entity_name
      entity[:username]
    end
  end

  class ServiceAccountUser < User
    def client_role_mappings(client_id)
      RbCloak::UserClientRoleMappings.new(client, self, client_id)
    end
  end
end
