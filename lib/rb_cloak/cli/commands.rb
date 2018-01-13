# frozen_string_literal: true

require 'clamp'

require_relative 'tools'
require_relative '../tools/logging'

module RbCloak
  module Cli
    class AbstractCommand < Clamp::Command
      extend RbCloak::Tools::LoggingSupport
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

      def say(message)
        message = message.upcase if verbose?
        puts message
      end
    end

    class AbstractSubCommand < AbstractCommand
      class << self
        def command
          action_name.downcase
        end

        def description
          "#{action_name} the entity"
        end

        def action_name
          @action_name ||= short_name.chomp('SubCommand')
        end
      end
    end

    class AbstractManageCommand < AbstractCommand
      class << self
        def entity_name
          short_name.chomp('Command')
        end

        def command
          entity_name.downcase
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