# frozen_string_literal: true

require_relative 'defaults'

module RbCloak
  # Documentation:
  # * REST: http://www.keycloak.org/docs-api/3.0/rest-api/index.html#_users_resource
  class Users < Defaults
    attr_reader :parent
    def initialize(client, parent)
      super(client)
      @parent = parent
    end

    def url
      parent.url + '/users'
    end
  end

  # USER_ENTITY: http://www.keycloak.org/docs-api/3.0/rest-api/index.html#_userrepresentation
  class User < Default
    def entity_id
      entity[:id]
    end

    def entity_name
      entity[:username]
    end
  end
end
