# frozen_string_literal: true

# frozen_string_literal: true

require_relative 'defaults'

module RbCloak
  # Documentation:
  # * REST: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_clients_resource
  class ClientPermissions < Defaults
    attr_reader :parent
    def initialize(client, parent)
      super(client)
      @parent = parent
    end

    def read
      list
    end

    def url
      parent.url + '/management/permissions'
    end
  end

  # Client Permissions: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_managementpermissionreference
  class ClientPermission < Default
    def entity_id
      entity[:resource]
    end

    def entity_name
      entity[:resource]
    end

    def update
      @client.update(@entity)
    end

    def read
      ent = @client.read
      @entity = ent.entity
    end
  end
end
