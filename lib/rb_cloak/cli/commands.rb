# frozen_string_literal: true

require 'clamp'

require_relative 'tools'
require_relative 'rbcloak_wrapper'
require_relative '../tools/logging'
require_relative 'mixins'

module RbCloak
  module Cli
    class AbstractCommand < Clamp::Command
      extend RbCloak::Tools::LoggingSupport
      include RbCloak::Tools::LoggingSupport
      class << self
        def short_name
          name.split('::').last
        end
      end

      option ['-v', '--verbose'], :flag, 'be verbose'

      option '--version', :flag, 'show version' do
        puts 'RbCloak-1.0'
        exit(0)
      end
    end

    class AbstractSubCommand < AbstractCommand
      class << self
        def command
          action_name.downcase
        end

        def description
          "#{action_name} the #{get_outer_class.entity_name.downcase}"
        end

        def action_name
          @action_name ||= short_name.chomp('SubCommand')
        end

        def get_outer_class
          @outer_class ||= begin
            outer_class_name = name.split('::')[-2]
            klass            = RbCloak::Cli::Entities.const_get(outer_class_name)
            klass
          end
        end
      end

      def client
        RbCloakWrapper.instance.client
      end

      def manager
        client.realms
      end

      def print_entity(obj)
        entity = obj.entity
        puts JSON.pretty_generate(entity)
      end

      def entity_name
        @entity_name ||= self.class.get_outer_class.entity_name
      end
    end

    class RealmBindAbstractSubCommand < AbstractSubCommand
      option ['--realm'], 'REALM', 'name of the realm', required: true

      def manager
        super.read(realm).method("#{entity_name.downcase}s".to_sym).call
      end
    end

    class AbstractManageCommand < AbstractCommand
      class << self
        def entity_name
          short_name.chomp('Command')
        end

        def command
          "#{entity_name.downcase}s"
        end

        def description
          "#{entity_name}s management command"
        end

        def load_entities
          entities = Tools.select_entities(self) do |e|
            cls_name = e.name
            cls_name.include?('SubCommand')
          end
          entities.each do |entity_command|
            log.debug("[SUB] Manage: #{entity_command.command} - #{entity_command}")
            subcommand entity_command.command, entity_command.description, entity_command
          end
        end
      end
    end
  end
end