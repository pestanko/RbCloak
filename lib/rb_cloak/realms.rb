# frozen_string_literal: true

require_relative 'defaults'
require_relative 'users'

module RbCloak
  # Realms administration:
  #   http://www.keycloak.org/docs-api/3.0/rest-api/index.html#_realms_admin_resource
  class Realms < Defaults
    def url
      super + '/realms'
    end

    def initialize(client)
      super(client)
    end
  end

  class Realm < Default
    def entity_id
      entity[:realm]
    end

    def users
      RbCloak::Users.new(client, self)
    end
  end
end
