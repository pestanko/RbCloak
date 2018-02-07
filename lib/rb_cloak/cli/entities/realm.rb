# frozen_string_literal: true

require 'clamp'

require_relative '../commands'

module RbCloak
  module Cli
    module Entities
      # Realm management command
      class RealmCommand < AbstractManageCommand
        class ListSubCommand < AbstractSubCommand
          include Mixins::AbstractListSubMixin
          print_params :realm
        end

        class ReadSubCommand < AbstractSubCommand
          include Mixins::AbstractReadSubMixin
          find_param :realm
        end

        class CreateSubCommand < AbstractSubCommand
          include Mixins::AbstractCreateSubMixin
        end

        class UpdateSubCommand < AbstractSubCommand
          include Mixins::AbstractUpdateSubMixin
          find_param :realm
        end

        class DeleteSubCommand < AbstractSubCommand
          include Mixins::AbstractDeleteSubMixin
          find_param :realm
        end

        load_entities
      end
    end
  end
end
