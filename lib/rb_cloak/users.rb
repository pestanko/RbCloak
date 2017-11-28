# frozen_string_literal: true

require_relative 'defaults'

module RbCloak
  class Users < Defaults
    attr_reader :parent
    def initialize(client, parent)
      super(client)
      @parent = parent
    end

    def url
      parent.url + '/users'
    end
  end

  class User < Default
    def entity_id
      entity_id[:id]
    end
  end
end
