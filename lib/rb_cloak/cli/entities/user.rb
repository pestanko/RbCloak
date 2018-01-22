# frozen_string_literal: true

require 'clamp'

require_relative '../commands'

module RbCloak
  module Cli
    module Entities
      # Realm management command
      class UserCommand < AbstractManageCommand

        class ListSubCommand < RealmBindAbstractSubCommand
          include Mixins::AbstractListSubMixin
          print_params :username
        end

        class ReadSubCommand < RealmBindAbstractSubCommand
          include Mixins::AbstractReadSubMixin
          find_param :username
        end

        class CreateSubCommand < RealmBindAbstractSubCommand
          include Mixins::AbstractCreateSubMixin
        end

        class UpdateSubCommand < RealmBindAbstractSubCommand
          include Mixins::AbstractUpdateSubMixin
          find_param :username
        end

        class DeleteSubCommand < RealmBindAbstractSubCommand
          include Mixins::AbstractDeleteSubMixin
          find_param :username
        end

        load_entities
      end
    end
  end
end