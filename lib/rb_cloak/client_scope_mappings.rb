# frozen_string_literal: true

require_relative 'defaults'

module RbCloak
  # Documentation:
  # * REST: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_clients_resource
  # URL: /{realm}/clients/{id}/scope-mappings/realm
  class ClientScopeMappings < Defaults
    attr_reader :parent
    def initialize(client, parent, client_id)
      super(client)
      @parent = parent
      @client_id = client_id
    end

    def url
      parent.url + "/scope-mappings/clients/#{@client_id}"
    end

    def available
      path = "#{url}/available"
      log.info("AVAILABLE #{manager_name}: #{path}")
      result = check_request { RestClient.get(path, headers) }
      log.debug("AVAILABLE response: #{result}")
      create_instance result
    end

    def composite
      path = "#{url}/composite"
      log.info("COMPOSITE #{manager_name}: #{path}")
      result = check_request { RestClient.get(path, headers) }
      log.debug("COMPOSITE: #{result}")
      create_instance result
    end
  end

  # ENTITY: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_rolerepresentation
  class ClientScopeMapping < Default
    def entity_id
      nil
    end

    def entity_name
      entity[:name]
    end
  end
end
