# frozen_string_literal: true

require 'clamp'

require_relative '../commands'

module RbCloak
  module Cli
    module Entities
      class RealmCommand < AbstractManageCommand
        class ListSubCommand < AbstractSubCommand
          def execute
            client.realms.list.each { |r| puts r[:realm] }
          end
        end
        class ReadSubCommand < AbstractSubCommand
          parameter 'realm_name', 'Realms name'
          def execute
            realm = client.realms.read(realm_name)
            print_entity(realm)
          end
        end

        class CreateSubCommand < AbstractSubCommand

        end

        class UpdateSubCommand < AbstractSubCommand

        end

        class DeleteSubCommand < AbstractSubCommand
          parameter 'realm_name', 'Realms name'
          def execute
            client.realms.delete(realm_name)
          end
        end

        load_entities

        def execute

        end
      end
    end
  end
end