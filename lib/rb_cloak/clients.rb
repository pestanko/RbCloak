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
      res[0] unless res.empty?
    end

    def service_account_user(client_id)
      path = "#{url}/#{client_id}/service-account-user"
      log.debug("SERVICE_ACCOUNT #{manager_name}: #{path}")
      result = check_request { RestClient.get(path, headers) }
      log.debug("SERVICE_ACCOUNT response: #{result}")
      create_instance result, klass: ServiceAccountUser, manager_bind: realm.users
    end

    def client_secret(client_id)
      path = "#{url}/#{client_id}/client-secret"
      log.debug("CLIENT_SECRET #{manager_name}: #{path}")
      result = check_request { RestClient.get(path, headers) }
      log.debug("CLIENT_SECRET response: #{result}")
      content = parse_response(result)
      content[:value]
    end
  end

  # CLIENT_ENTITY: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_clientrepresentation
  class Client < Default
    def realm
      client.realm
    end

    def entity_id
      entity[:id]
    end

    def entity_name
      entity[:name]
    end

    def secret
      client.client_secret(entity_id)
    end

    def client_id
      entity[:clientId]
    end

    def credentials
      { clientId: entity[:clientId], secret: secret }
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
