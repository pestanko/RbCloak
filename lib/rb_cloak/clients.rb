# frozen_string_literal: true

require_relative 'defaults'
require_relative 'roles'

module RbCloak
  # Documentation:
  # * REST: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_clients_resource
  class Clients < Defaults
    attr_reader :parent
    def initialize(client, parent)
      super(client)
      @parent = parent
    end

    def url
      parent.url + '/clients'
    end
  end

  # CLIENT_ENTITY: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_clientrepresentation
  class Client < Default
    def entity_id
      entity[:id]
    end

    def entity_name
      entity[:name]
    end

    def roles
      RbCloak::Roles.new(client, self)
    end
  end
end
