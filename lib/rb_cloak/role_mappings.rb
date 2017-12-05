# frozen_string_literal: true

require_relative 'defaults'
require_relative 'client_roles'
require_relative 'client_permissions'


module RbCloak
  # Documentation:
  # * REST: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_role_mapper_resource
  class RoleMappings < Defaults
    attr_reader :parent
    def initialize(client, parent)
      super(client)
      @parent = parent
    end

    def url
      parent.url + '/role-mappings'
    end
  end

  # ENTITY: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_mappingsrepresentation
  class RoleMapping < Default
    def entity_id
      entity[:id]
    end

    def entity_name
      entity[:name]
    end
  end
end
