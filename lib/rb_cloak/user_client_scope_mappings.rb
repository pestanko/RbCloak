# frozen_string_literal: true

require_relative 'defaults'

module RbCloak
  # Documentation:
  # * REST: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_clients_resource
  # URL: /{realm}/clients/{id}/scope-mappings/realm
  class UserClientRoleMappings < Defaults
    attr_reader :parent
    def initialize(client, parent, client_id)
      super(client)
      @parent = parent
      @client_id = client_id
    end

    def add_mappings(*mappings)
      extracted = mappings.map(&:entity)
      create(extracted)
    end

    def url
      parent.url + "/role-mappings/clients/#{@client_id}"
    end

    def available
      path = "#{url}/available"
      log.debug("AVAILABLE #{manager_name}: #{path}")
      result = check_request { RestClient.get(path, headers) }
      log.debug("AVAILABLE response: #{result}")
      create_instance result
    end

    def composite
      path = "#{url}/composite"
      log.debug("COMPOSITE #{manager_name}: #{path}")
      result = check_request { RestClient.get(path, headers) }
      log.debug("COMPOSITE response : #{result}")
      create_instance result
    end
  end

  # ENTITY: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_rolerepresentation
  class UserClientRoleMapping < Default
    def entity_id
      nil
    end

    def entity_name
      entity[:name]
    end
  end
end
