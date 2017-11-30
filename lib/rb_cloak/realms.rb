# frozen_string_literal: true

require_relative 'defaults'
require_relative 'users'
require_relative 'clients'
require_relative 'groups'
require_relative 'identity_providers'

module RbCloak
  # Realms administration:
  #   http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_realms_admin_resource
  class Realms < Defaults
    def url
      super + '/realms'
    end

    def initialize(client)
      super(client)
    end
  end

  # http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_realmrepresentation
  class Realm < Default
    def entity_id
      entity[:realm]
    end

    def entity_name
      entity[:realm]
    end

    def users
      RbCloak::Users.new(client, self)
    end

    def clients
      RbCloak::Clients.new(client, self)
    end

    def groups
      RbCloak::Groups.new(client, self)
    end

    def identity_providers
      RbCloak::IdentityProviders.new(client, self)
    end
  end
end
