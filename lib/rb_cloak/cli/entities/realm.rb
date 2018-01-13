# frozen_string_literal: true

require 'clamp'

require_relative '../commands'

module RbCloak
  module Cli
    module Entities
      class RealmCommand < AbstractManageCommand
        class ListSubCommand < AbstractSubCommand

        end
        class ReadSubCommand < AbstractSubCommand

        end

        class CreateSubCommand < AbstractSubCommand

        end

        class UpdateSubCommand < AbstractSubCommand

        end

        class DeleteSubCommand < AbstractSubCommand

        end

        load_entities

        def execute

        end
      end
    end
  end
end