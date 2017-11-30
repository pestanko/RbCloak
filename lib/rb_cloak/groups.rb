# frozen_string_literal: true

require_relative 'defaults'

module RbCloak
  # Documentation:
  # * REST: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_groups_resource
  class Groups < Defaults
    attr_reader :parent
    def initialize(client, parent)
      super(client)
      @parent = parent
    end

    def url
      parent.url + '/groups'
    end
  end

  # USER_ENTITY: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_grouprepresentation
  class Group < Default
    def entity_id
      entity[:id]
    end

    def entity_name
      entity[:name]
    end
  end
end
