# frozen_string_literal: true

require_relative 'defaults'
require_relative 'client_roles'
require_relative 'client_permissions'


module RbCloak
  # Documentation:
  # * REST: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_clients_resource
  class ClientTemplates < Defaults
    attr_reader :parent
    def initialize(client, parent)
      super(client)
      @parent = parent
    end

    def url
      parent.url + '/client-templates'
    end
  end

  # CLIENT_ENTITY: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_clientrepresentation
  class ClientTemplate < Default
    def entity_id
      entity[:id]
    end

    def entity_name
      entity[:name]
    end
  end
end
