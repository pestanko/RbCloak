# frozen_string_literal: true

require_relative 'defaults'

module RbCloak
  # Documentation:
  # * REST: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_identity_providers_resource
  class IdentityProviders < Defaults
    attr_reader :parent
    def initialize(client, parent)
      super(client)
      @parent = parent
    end

    def url
      parent.url + '/identity-provider/instances'
    end
  end

  # IdentityProvider_ENTITY: http://www.keycloak.org/docs-api/3.4/rest-api/index.html#_identityproviderrepresentation
  class IdentityProvider < Default
    def entity_id
      entity[:id]
    end

    def entity_name
      entity[:alias]
    end
  end
end
