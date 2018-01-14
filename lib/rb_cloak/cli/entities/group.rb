# frozen_string_literal: true

require 'clamp'

require_relative '../commands'

module RbCloak
  module Cli
    module Entities
      # Realm management command
      class GroupCommand < AbstractManageCommand

        class ListSubCommand < RealmBindAbstractSubCommand
          include Mixins::AbstractListSubMixin
          print_params :name
        end

        class ReadSubCommand < RealmBindAbstractSubCommand
          include Mixins::AbstractReadSubMixin
          find_param :name
        end

        class CreateSubCommand < RealmBindAbstractSubCommand
          # TODO
        end

        class UpdateSubCommand < RealmBindAbstractSubCommand
          # TODO
        end

        class DeleteSubCommand < RealmBindAbstractSubCommand
          include Mixins::AbstractDeleteSubMixin
          find_param :name
        end

        load_entities
      end
    end
  end
end