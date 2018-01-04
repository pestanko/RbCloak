# frozen_string_literal: true

require_relative 'defaults'
require_relative 'client_roles'
require_relative 'client_permissions'
require_relative 'realm_scope_mappings'
require_relative 'client_scope_mappings'
require_relative 'users'


module RbCloak
  # Documentation:
  # * REST: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_clients_resource
  class Clients < Defaults
    attr_reader :parent

    alias realm parent

    def initialize(client, parent)
      super(client)
      @parent = parent
    end

    def url
      parent.url + '/clients'
    end

    def find_by_client_id(client_id)
      res = find { |client| client['clientId'] == client_id }
      res[0] if res
    end

    def service_account_user(client_id)
      path = "#{url}/#{client_id}/service-account-user"
      log.debug("SERVICE_ACCOUNT #{manager_name}: #{path}")
      result = make_request { RestClient.get(path, headers) }
      log.debug("SERVICE_ACCOUNT response: #{result}")
      create_instance result, klass: ServiceAccountUser, manager_bind: realm.users
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

    def service_account
      client.service_account_user(entity_id)
    end

    def roles
      RbCloak::ClientRoles.new(client, self)
    end

    def permissions
      RbCloak::ClientPermissions.new(client, self)
    end

    def realm_scope_mappings
      RbCloak::ClientRealmScopeMappings.new(client, self)
    end

    def client_scope_mappings(client_id)
      RbCloak::ClientScopeMappings.new(client, self, client_id)
    end
  end
end
